extends Node
class_name BoardManager

@export var slots_root: Node
@export var card_scene: PackedScene
@export var phase_manager: PhaseManager

func request_place_card(card: Card, slot: NewSlots) -> void:
	if card == null:
		return

	if slot == null:
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

	if multiplayer.multiplayer_peer == null:
		apply_place_card(snapshot)
		return

	if multiplayer.is_server():
		host_resolve_place_card(snapshot)
	else:
		rpc_id(1, "request_place_card_from_host", snapshot)

@rpc("any_peer", "call_remote", "reliable")
func request_place_card_from_host(snapshot: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	var sender_peer_id := multiplayer.get_remote_sender_id()
	var owner_peer_id: int = snapshot["owner_peer_id"]

	if sender_peer_id != owner_peer_id:
		print("Host place blocked: sender does not own card")
		return

	host_resolve_place_card(snapshot)

func host_resolve_place_card(snapshot: Dictionary) -> void:
	if phase_manager != null and not phase_manager.is_place_phase():
		print("Host place blocked: not place phase")
		return

	var owner_peer_id: int = snapshot["owner_peer_id"]
	var lane_id: int = snapshot["lane_id"]

	var target_slot := find_visual_slot_for_owner(owner_peer_id, lane_id)
	if target_slot == null:
		print("Host place blocked: target slot not found")
		return

	if not target_slot.is_empty():
		print("Host place blocked: target slot occupied")
		return

	apply_place_card(snapshot)
	rpc("commit_place_card", snapshot)

@rpc("authority", "call_remote", "reliable")
func commit_place_card(snapshot: Dictionary) -> void:
	apply_place_card(snapshot)

func apply_place_card(snapshot: Dictionary) -> void:
	var card_id: int = snapshot["card_id"]
	var owner_peer_id: int = snapshot["owner_peer_id"]
	var lane_id: int = snapshot["lane_id"]

	var target_slot := find_visual_slot_for_owner(owner_peer_id, lane_id)

	if target_slot == null:
		print("apply_place_card failed: slot not found")
		return

	if not target_slot.is_empty():
		print("apply_place_card blocked: slot occupied")
		return

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		card = spawn_card_from_snapshot(snapshot)

	if card == null:
		print("apply_place_card failed: card missing")
		return

	apply_snapshot_to_card(card, snapshot)
	card.place_into_slot(target_slot)

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
	card.multiplayer_card_id = snapshot["card_id"]
	card.owning_peer_id = snapshot["owner_peer_id"]
	card.card_name = snapshot["card_name"]
	card.current_attack = snapshot["attack"]
	card.current_health = snapshot["health"]
	card.current_cost = snapshot["cost"]
	card.current_worth = snapshot["worth"]

	if multiplayer.multiplayer_peer != null and multiplayer.get_unique_id() == card.owning_peer_id:
		card.card_owner = Card.Owner.PLAYER
	else:
		card.card_owner = Card.Owner.OPPONENT

	if card.stats != null:
		card.stats.update_health(card.current_health)

func find_visual_slot_for_owner(owner_peer_id: int, lane_id: int) -> NewSlots:
	var wanted_owner := NewSlots.SlotOwner.OPPONENT

	if multiplayer.multiplayer_peer == null:
		wanted_owner = NewSlots.SlotOwner.PLAYER
	elif multiplayer.get_unique_id() == owner_peer_id:
		wanted_owner = NewSlots.SlotOwner.PLAYER

	return find_slot_by_lane_and_owner(slots_root, lane_id, wanted_owner)

func find_slot_by_lane_and_owner(node: Node, lane_id: int, slot_owner: NewSlots.SlotOwner) -> NewSlots:
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

func find_card_by_multiplayer_data_recursive(node: Node, card_id: int, owner_peer_id: int) -> Card:
	var card := node as Card

	if card != null:
		if card.multiplayer_card_id == card_id and card.owning_peer_id == owner_peer_id:
			return card

	for child in node.get_children():
		var found := find_card_by_multiplayer_data_recursive(child, card_id, owner_peer_id)
		if found != null:
			return found

	return null
