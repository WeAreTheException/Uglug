extends Node
class_name CombatManager

@export var slots_root: Node
@export var turn_manager: TurnManager
@export var delay_between_attacks: float = 0.35
@export var delay_between_sides: float = 0.6

var attack_round_running: bool = false

func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(request_attack_from_host)
	GDSync.expose_func(commit_attack_remote)

	print("CombatManager ready / GDSync host = ", GDSync.is_host())

func start_attack_round() -> void:
	if not GDSync.is_host():
		return

	if attack_round_running:
		return

	if turn_manager == null:
		print("attack round blocked: turn_manager is null")
		return

	attack_round_running = true

	var host_id := turn_manager.player_one_id
	var client_id := turn_manager.player_two_id

	await _run_attack_side(host_id)
	await get_tree().create_timer(delay_between_sides).timeout
	await _run_attack_side(client_id)

	attack_round_running = false

func _run_attack_side(owner_peer_id: int) -> void:
	var slots := get_slots_for_owner_left_to_right(owner_peer_id)

	for slot in slots:
		if slot == null:
			continue

		var card := slot.current_card as Card

		if card == null:
			continue

		if card.multiplayer_card_id < 0:
			continue

		GDSync.call_func_all(commit_attack_remote, card.multiplayer_card_id)

		await get_tree().create_timer(delay_between_attacks).timeout

func get_slots_for_owner_left_to_right(owner_peer_id: int) -> Array[NewSlots]:
	var found_slots: Array[NewSlots] = []

	_collect_slots_for_owner(slots_root, owner_peer_id, found_slots)

	found_slots.sort_custom(func(a: NewSlots, b: NewSlots) -> bool:
		return a.lane_id < b.lane_id
	)

	return found_slots

func _collect_slots_for_owner(node: Node, owner_peer_id: int, found_slots: Array[NewSlots]) -> void:
	if node == null:
		return

	var slot := node as NewSlots

	if slot != null:
		var visual_slot := find_visual_slot_for_owner(owner_peer_id, slot.lane_id)

		if visual_slot == slot:
			found_slots.append(slot)

	for child in node.get_children():
		_collect_slots_for_owner(child, owner_peer_id, found_slots)

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

func request_attack(card: Card) -> void:
	if card == null:
		return

	if card.multiplayer_card_id < 0:
		print("attack sync blocked: card has no multiplayer_card_id")
		return

	var my_peer_id := int(GDSync.get_client_id())

	if GDSync.is_host():
		_host_resolve_attack(my_peer_id, card.multiplayer_card_id)
	else:
		GDSync.call_func(request_attack_from_host, my_peer_id, card.multiplayer_card_id)

func request_attack_from_host(requesting_peer_id: int, attacker_card_id: int) -> void:
	if not GDSync.is_host():
		return

	_host_resolve_attack(requesting_peer_id, attacker_card_id)

func _host_resolve_attack(requesting_peer_id: int, attacker_card_id: int) -> void:
	var attacker := find_card_by_id(attacker_card_id)

	if attacker == null:
		print("attack blocked: attacker missing on host id=", attacker_card_id)
		return

	if attacker.owning_peer_id != requesting_peer_id:
		print("attack blocked: peer does not own card")
		return

	GDSync.call_func_all(commit_attack_remote, attacker_card_id)

func commit_attack_remote(attacker_card_id: int) -> void:
	var attacker := find_card_by_id(attacker_card_id)

	if attacker == null:
		print("remote attack blocked: attacker missing id=", attacker_card_id)
		return

	if attacker.attack_handler == null:
		print("remote attack blocked: attack_handler missing on ", attacker.card_name)
		return

	attacker.attack_handler.attack()

func find_card_by_id(card_id: int) -> Card:
	var cards := get_tree().get_nodes_in_group("cards")

	for node in cards:
		var card := node as Card

		if card == null:
			continue

		if card.multiplayer_card_id == card_id:
			return card

	return null
