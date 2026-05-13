extends Node
class_name BoardManager

@export var slots_root: Node
@export var card_scene: PackedScene
@export var phase_manager: PhaseManager

func _ready() -> void:
	GDSync.expose_node(self)

	GDSync.expose_func(request_place_card_from_client)
	GDSync.expose_func(commit_place_card)

	GDSync.expose_func(request_discard_card_from_client)
	GDSync.expose_func(commit_discard_card)

	print("BoardManager ready / GDSync host = ", GDSync.is_host())

func request_place_card(card: Card, slot: NewSlots) -> void:
	print("BOARD request_place_card")

	if card == null:
		print("BoardManager place blocked: card is null")
		return

	if slot == null:
		print("BoardManager place blocked: slot is null")
		return

	if phase_manager != null and not phase_manager.is_place_phase():
		print("BoardManager place blocked: not place phase")
		return

	if card.card_owner != Card.Owner.PLAYER:
		print("BoardManager place blocked: not player card")
		return

	if slot.slot_owner != NewSlots.SlotOwner.PLAYER:
		print("BoardManager place blocked: not player slot")
		return

	if not slot.is_empty():
		print("BoardManager place blocked: slot occupied")
		return

	var snapshot := make_card_snapshot(card, slot.lane_id)

	print("BOARD snapshot made: ", snapshot)

	if GDSync.is_host():
		host_resolve_place_card(snapshot)
	else:
		print("BOARD sending request to host")
		GDSync.call_func(request_place_card_from_client, snapshot)

func request_place_card_from_client(snapshot: Dictionary) -> void:
	print("BOARD host received client place request: ", snapshot)

	if not GDSync.is_host():
		print("BOARD ignored request because this machine is not host")
		return

	host_resolve_place_card(snapshot)

func host_resolve_place_card(snapshot: Dictionary) -> void:
	print("BOARD host_resolve_place_card: ", snapshot)

	if phase_manager != null and not phase_manager.is_place_phase():
		print("Host place blocked: not place phase")
		return

	var owner_peer_id: int = int(snapshot["owner_peer_id"])
	var lane_id: int = int(snapshot["lane_id"])

	var target_slot := find_visual_slot_for_owner(owner_peer_id, lane_id)
	if target_slot == null:
		print("Host place blocked: target slot not found")
		return

	if not target_slot.is_empty():
		print("Host place blocked: target slot occupied")
		return

	print("BOARD host approved placement, broadcasting")

	GDSync.call_func_all(commit_place_card, snapshot)

func commit_place_card(snapshot: Dictionary) -> void:
	print("BOARD commit_place_card received: ", snapshot)
	apply_place_card(snapshot)

func apply_place_card(snapshot: Dictionary) -> void:
	var card_id: int = int(snapshot["card_id"])
	var owner_peer_id: int = int(snapshot["owner_peer_id"])
	var lane_id: int = int(snapshot["lane_id"])

	var target_slot := find_visual_slot_for_owner(owner_peer_id, lane_id)

	if target_slot == null:
		print("apply_place_card failed: slot not found lane=", lane_id, " owner_peer=", owner_peer_id)
		return

	if not target_slot.is_empty():
		print("apply_place_card blocked: slot occupied lane=", lane_id)
		return

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		print("apply_place_card: card not found, spawning from snapshot")
		card = spawn_card_from_snapshot(snapshot)
	else:
		print("apply_place_card: found existing card ", card.card_name)

	if card == null:
		print("apply_place_card failed: card missing")
		return

	apply_snapshot_to_card(card, snapshot)

	print("BOARD placing card ", card.card_name, " into lane ", lane_id)

	card.place_into_slot(target_slot)

func request_discard_card(card: Card) -> void:
	if card == null:
		print("discard blocked: card is null")
		return

	if card.current_slot == null:
		print("discard blocked: card is not in slot")
		return

	if card.card_owner != Card.Owner.PLAYER:
		print("discard blocked: not your card")
		return

	var snapshot := {
		"card_id": card.multiplayer_card_id,
		"owner_peer_id": card.owning_peer_id
	}

	if GDSync.is_host():
		host_resolve_discard_card(snapshot)
	else:
		GDSync.call_func(request_discard_card_from_client, snapshot)

func request_discard_card_from_client(snapshot: Dictionary) -> void:
	if not GDSync.is_host():
		return

	host_resolve_discard_card(snapshot)

func host_resolve_discard_card(snapshot: Dictionary) -> void:
	var card_id: int = int(snapshot["card_id"])
	var owner_peer_id: int = int(snapshot["owner_peer_id"])

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		print("host discard blocked: card not found")
		return

	if card.current_slot == null:
		print("host discard blocked: card not in slot")
		return

	GDSync.call_func_all(commit_discard_card, snapshot)

func commit_discard_card(snapshot: Dictionary) -> void:
	var card_id: int = int(snapshot["card_id"])
	var owner_peer_id: int = int(snapshot["owner_peer_id"])

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		print("commit discard: card not found")
		return

	card.discard()

func make_card_snapshot(card: Card, lane_id: int) -> Dictionary:
	return {
		"card_id": card.multiplayer_card_id,
		"owner_peer_id": card.owning_peer_id,
		"card_name": card.card_name,
		"attack": card.current_attack,
		"health": card.current_health,
		"cost": card.current_cost,
		"worth": card.current_worth,
		"lane_id": lane_id
	}

func spawn_card_from_snapshot(snapshot: Dictionary) -> Card:
	if card_scene == null:
		print("spawn_card_from_snapshot failed: card_scene is null")
		return null

	var new_card := card_scene.instantiate() as Card
	if new_card == null:
		print("spawn_card_from_snapshot failed: scene is not Card")
		return null

	get_tree().current_scene.add_child(new_card)

	new_card.select_handler = null
	new_card.player_hand = null

	return new_card

func apply_snapshot_to_card(card: Card, snapshot: Dictionary) -> void:
	card.multiplayer_card_id = int(snapshot["card_id"])
	card.owning_peer_id = int(snapshot["owner_peer_id"])
	card.card_name = str(snapshot["card_name"])
	card.current_attack = int(snapshot["attack"])
	card.current_health = int(snapshot["health"])
	card.current_cost = int(snapshot["cost"])
	card.current_worth = int(snapshot["worth"])

	if int(GDSync.get_client_id()) == card.owning_peer_id:
		card.card_owner = Card.Owner.PLAYER
	else:
		card.card_owner = Card.Owner.OPPONENT

	if card.stats != null:
		card.stats.update_health(card.current_health)

func find_visual_slot_for_owner(owner_peer_id: int, lane_id: int) -> NewSlots:
	var wanted_owner := NewSlots.SlotOwner.OPPONENT

	if int(GDSync.get_client_id()) == owner_peer_id:
		wanted_owner = NewSlots.SlotOwner.PLAYER

	return find_slot_by_lane_and_owner(slots_root, lane_id, wanted_owner)

func find_slot_by_lane_and_owner(
	node: Node,
	lane_id: int,
	slot_owner: NewSlots.SlotOwner
) -> NewSlots:
	if node == null:
		return null

	var slot := node as NewSlots
	if slot != null:
		if slot.lane_id == lane_id and slot.slot_owner == slot_owner:
			return slot

	for child in node.get_children():
		var found := find_slot_by_lane_and_owner(child, lane_id, slot_owner)
		if found != null:
			return found

	return null

func find_card_by_multiplayer_data(card_id: int, owner_peer_id: int) -> Card:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	return find_card_by_multiplayer_data_recursive(scene, card_id, owner_peer_id)

func find_card_by_multiplayer_data_recursive(
	node: Node,
	card_id: int,
	owner_peer_id: int
) -> Card:
	var card := node as Card

	if card != null:
		if card.multiplayer_card_id == card_id and card.owning_peer_id == owner_peer_id:
			return card

	for child in node.get_children():
		var found := find_card_by_multiplayer_data_recursive(child, card_id, owner_peer_id)
		if found != null:
			return found

	return null

func request_add_mutation_to_card(card: Card, mutation: Mutation) -> void:
	if card == null:
		return

	if mutation == null:
		return

	if mutation.resource_path == "":
		print("mutation sync blocked: mutation resource_path is empty")
		return

	var snapshot := {
		"card_id": card.multiplayer_card_id,
		"owner_peer_id": card.owning_peer_id,
		"mutation_path": mutation.resource_path
	}

	if GDSync.is_host():
		host_resolve_add_mutation(snapshot)
	else:
		GDSync.call_func(request_add_mutation_from_client, snapshot)

func request_add_mutation_from_client(snapshot: Dictionary) -> void:
	if not GDSync.is_host():
		return

	host_resolve_add_mutation(snapshot)

func host_resolve_add_mutation(snapshot: Dictionary) -> void:
	var card_id: int = int(snapshot["card_id"])
	var owner_peer_id: int = int(snapshot["owner_peer_id"])

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		print("host mutation sync blocked: card not found")
		return

	GDSync.call_func_all(commit_add_mutation_to_card, snapshot)

func commit_add_mutation_to_card(snapshot: Dictionary) -> void:
	var card_id: int = int(snapshot["card_id"])
	var owner_peer_id: int = int(snapshot["owner_peer_id"])
	var mutation_path: String = str(snapshot["mutation_path"])

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		print("commit mutation sync blocked: card not found")
		return

	card.add_additional_mutation_from_path(mutation_path)
