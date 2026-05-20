extends Node
class_name AntlerAttackResolver

@export var delay_between_attacks: float = 0.25

var attack_handler: AttackHandler = null
var card: Card = null


func resolve() -> bool:
	_refresh_card()

	if card == null:
		return false

	if attack_handler == null:
		return false

	if not has_antler():
		return false

	var should_apply_damage := GDSync.is_host()
	var slots := get_antler_slots()

	for slot in slots:
		if slot == null:
			continue

		var target := slot.current_card as Card

		if target != null:
			if should_apply_damage:
				await attack_handler.resolve_card_attack_from_external(target)
			else:
				attack_handler.play_attack_visual_from_external(target)
		else:
			if should_apply_damage:
				await attack_handler.resolve_direct_attack_from_external(slot)
			else:
				attack_handler.play_direct_attack_visual_from_external(slot)

		if delay_between_attacks > 0.0:
			await get_tree().create_timer(delay_between_attacks).timeout

	return true


func has_antler() -> bool:
	_refresh_card()

	if card == null:
		return false

	for mutation in card.base_mutations:
		if mutation is Antler:
			return true

	for mutation in card.additional_mutations:
		if mutation is Antler:
			return true

	return false


func get_antler_slots() -> Array[NewSlots]:
	var slots: Array[NewSlots] = []

	_refresh_card()

	if card == null:
		return slots

	if card.current_slot == null:
		return slots

	var front_slot := card.current_slot.opposing_slot
	if front_slot == null:
		return slots

	var root := _get_slots_root()
	if root == null:
		return slots

	var enemy_slots := _get_slots_for_owner(root, front_slot.slot_owner)

	var lower_lane_slot := _get_slot_by_lane(enemy_slots, front_slot.lane_id - 1)
	var higher_lane_slot := _get_slot_by_lane(enemy_slots, front_slot.lane_id + 1)

	if _card_owner_is_player_one():
		_add_slot(slots, lower_lane_slot)
		_add_slot(slots, higher_lane_slot)
	else:
		_add_slot(slots, higher_lane_slot)
		_add_slot(slots, lower_lane_slot)

	print("ANTLER owner peer=", card.owning_peer_id)
	print("ANTLER p1 peer=", _get_player_one_id())
	print("ANTLER front lane=", front_slot.lane_id)
	print("ANTLER final slots=", slots)

	return slots


func _add_slot(slots: Array[NewSlots], slot: NewSlots) -> void:
	if slot == null:
		return

	slots.append(slot)


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
	_refresh_card()

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


func _refresh_card() -> void:
	if card == null:
		card = get_parent() as Card

	if attack_handler == null and card != null:
		attack_handler = card.attack_handler
