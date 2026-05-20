extends Mutation
class_name Antler

var empty_adjacent_attack_count: int = 0
var empty_adjacent_slots: Array[NewSlots] = []
var ordered_adjacent_slots: Array[NewSlots] = []


func get_attack_targets(card: Card, _current_targets: Array[Card]) -> Array[Card]:
	var targets: Array[Card] = []

	empty_adjacent_attack_count = 0
	empty_adjacent_slots.clear()
	ordered_adjacent_slots.clear()

	if card == null:
		return targets

	if card.current_slot == null:
		return targets

	var front_slot := card.current_slot.opposing_slot
	if front_slot == null:
		return targets

	var root := _get_slots_root(card)
	if root == null:
		return targets

	var enemy_slots := _get_slots_for_owner(root, front_slot.slot_owner)

	var left_slot := _find_slot_by_lane(enemy_slots, front_slot.lane_id - 1)
	var right_slot := _find_slot_by_lane(enemy_slots, front_slot.lane_id + 1)

	if _card_attacks_left_to_right(card):
		_add_ordered_slot(left_slot)
		_add_ordered_slot(right_slot)
	else:
		_add_ordered_slot(right_slot)
		_add_ordered_slot(left_slot)

	for slot in ordered_adjacent_slots:
		_add_slot_or_direct(targets, slot)

	print("ANTLER card slot=", card.current_slot, " lane=", card.current_slot.lane_id)
	print("ANTLER front slot=", front_slot, " lane=", front_slot.lane_id)
	print("ANTLER left slot=", left_slot, " lane=", left_slot.lane_id if left_slot != null else "null")
	print("ANTLER right slot=", right_slot, " lane=", right_slot.lane_id if right_slot != null else "null")
	print("ANTLER ordered slots=", ordered_adjacent_slots)
	print("ANTLER target count=", targets.size())
	print("ANTLER empty direct count=", empty_adjacent_attack_count)

	return targets


func _add_ordered_slot(slot: NewSlots) -> void:
	if slot == null:
		return

	ordered_adjacent_slots.append(slot)


func _add_slot_or_direct(targets: Array[Card], slot: NewSlots) -> void:
	if slot == null:
		return

	if slot.current_card == null:
		empty_adjacent_attack_count += 1
		empty_adjacent_slots.append(slot)
		return

	var target_card := slot.current_card as Card

	if target_card != null:
		targets.append(target_card)


func _card_attacks_left_to_right(card: Card) -> bool:
	if card == null:
		return true

	if card.current_slot == null:
		return true

	return card.current_slot.slot_owner == NewSlots.SlotOwner.PLAYER


func _find_slot_by_lane(slots: Array[NewSlots], wanted_lane_id: int) -> NewSlots:
	for slot in slots:
		if slot == null:
			continue

		if slot.lane_id == wanted_lane_id:
			return slot

	return null


func _get_slots_root(card: Card) -> Node:
	if card.combat_manager != null:
		if card.combat_manager.slots_root != null:
			return card.combat_manager.slots_root

	return card.get_tree().current_scene


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
