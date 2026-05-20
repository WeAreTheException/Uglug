extends Node
class_name AntlerAttackResolver

@export var delay_between_attacks: float = 0.25

var card: Card = null
var attack_handler: AttackHandler = null
var executor: AntlerAttackExecutor = null


func _ready() -> void:
	_refresh_refs()

	GDSync.expose_node(self)
	GDSync.expose_func(run_synced_antler_attack)


func resolve() -> bool:
	_refresh_refs()

	if card == null:
		return false

	if attack_handler == null:
		return false

	if executor == null:
		return false

	if not has_antler():
		return false

	if not GDSync.is_host():
		print("Antler waiting for host synced attack")
		return true

	var lanes := get_antler_lanes()

	print("HOST SYNCING ANTLER LANES: ", lanes)

	GDSync.call_func_all(run_synced_antler_attack, lanes)

	return true


func run_synced_antler_attack(lanes: Array) -> void:
	_refresh_refs()

	if card == null:
		return

	if attack_handler == null:
		return

	if executor == null:
		return

	if card.current_slot == null:
		return

	var front_slot := card.current_slot.opposing_slot

	if front_slot == null:
		return

	var root := _get_slots_root()

	if root == null:
		return

	var enemy_slots := _get_slots_for_owner(root, front_slot.slot_owner)

	print("RUN SYNCED ANTLER peer=", int(GDSync.get_client_id()), " owner=", card.owning_peer_id, " lanes=", lanes)

	for lane in lanes:
		var lane_id := int(lane)
		var slot := _get_slot_by_lane(enemy_slots, lane_id)

		if slot == null:
			print("ANTLER synced lane missing: ", lane_id)
			continue

		var target := slot.current_card as Card

		if target != null:
			await executor.resolve_card_attack(target, attack_handler.attack_anim)
		else:
			await executor.resolve_direct_attack(slot, attack_handler.attack_anim)

		if delay_between_attacks > 0.0:
			await get_tree().create_timer(delay_between_attacks).timeout


func has_antler() -> bool:
	_refresh_refs()

	if card == null:
		return false

	for mutation in card.base_mutations:
		if mutation is Antler:
			return true

	for mutation in card.additional_mutations:
		if mutation is Antler:
			return true

	return false


func get_antler_lanes() -> Array[int]:
	var lanes: Array[int] = []

	_refresh_refs()

	if card == null:
		return lanes

	if card.current_slot == null:
		return lanes

	var front_slot := card.current_slot.opposing_slot

	if front_slot == null:
		return lanes

	var lower_lane := front_slot.lane_id - 1
	var higher_lane := front_slot.lane_id + 1

	if _card_owner_is_player_one():
		lanes.append(lower_lane)
		lanes.append(higher_lane)
	else:
		lanes.append(higher_lane)
		lanes.append(lower_lane)

	print("ANTLER LANES owner peer=", card.owning_peer_id)
	print("ANTLER LANES player one=", _get_player_one_id())
	print("ANTLER LANES front lane=", front_slot.lane_id)
	print("ANTLER LANES final=", lanes)

	return lanes


func _card_owner_is_player_one() -> bool:
	return card.owning_peer_id == _get_player_one_id()


func _get_player_one_id() -> int:
	var tree := get_tree()

	if tree == null:
		return -1

	var turn_manager := tree.get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		return -1

	return turn_manager.player_one_id


func _get_slot_by_lane(slots: Array[NewSlots], lane_id: int) -> NewSlots:
	for slot in slots:
		if slot == null:
			continue

		if slot.lane_id == lane_id:
			return slot

	return null


func _get_slots_root() -> Node:
	_refresh_refs()

	if card != null:
		if card.combat_manager != null:
			if card.combat_manager.slots_root != null:
				return card.combat_manager.slots_root

	return get_tree().current_scene


func _get_slots_for_owner(root: Node, wanted_owner: NewSlots.SlotOwner) -> Array[NewSlots]:
	var slots: Array[NewSlots] = []
	_collect_slots_for_owner(root, wanted_owner, slots)
	return slots


func _collect_slots_for_owner(node: Node, wanted_owner: NewSlots.SlotOwner, found: Array[NewSlots]) -> void:
	if node == null:
		return

	var slot := node as NewSlots

	if slot != null:
		if slot.slot_owner == wanted_owner:
			found.append(slot)

	for child in node.get_children():
		_collect_slots_for_owner(child, wanted_owner, found)


func _refresh_refs() -> void:
	if card == null:
		card = get_parent() as Card

	if attack_handler == null and card != null:
		attack_handler = card.attack_handler

	if executor == null and card != null:
		executor = card.get_node_or_null("AntlerAttackExecutor") as AntlerAttackExecutor
