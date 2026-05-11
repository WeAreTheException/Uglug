extends Mutation
class_name Antler

var empty_adjacent_attack_count: int = 0
var empty_adjacent_slots: Array[NewSlots] = []

func get_attack_targets(card: Card, _current_targets: Array[Card]) -> Array[Card]:
	var targets: Array[Card] = []
	empty_adjacent_attack_count = 0
	empty_adjacent_slots.clear()

	if card == null:
		return targets

	if card.current_slot == null:
		return targets

	var front_slot = card.current_slot.opposing_slot

	if front_slot == null:
		return targets

	var left_lane: int = front_slot.lane_id - 1
	var right_lane: int = front_slot.lane_id + 0

	var left_slot = _find_slot_by_lane(card, left_lane, front_slot.slot_owner)
	var right_slot = _find_slot_by_lane(card, right_lane, front_slot.slot_owner)

	_add_slot_or_direct(targets, left_slot)
	_add_slot_or_direct(targets, right_slot)

	print("ANTLER front lane=", front_slot.lane_id)
	print("ANTLER left slot=", left_slot)
	print("ANTLER right slot=", right_slot)
	print("ANTLER target count=", targets.size())
	print("ANTLER empty direct count=", empty_adjacent_attack_count)

	return targets


func _add_slot_or_direct(targets: Array[Card], slot: NewSlots) -> void:
	if slot == null:
		return

	if slot.current_card == null:
		empty_adjacent_attack_count += 1
		empty_adjacent_slots.append(slot)
		return

	targets.append(slot.current_card)


func _find_slot_by_lane(card: Card, lane_id: int, slot_owner: int) -> NewSlots:
	var root := card.get_tree().current_scene

	if root == null:
		return null

	var slots := _get_all_slots(root)

	for slot in slots:
		if slot.lane_id == lane_id and slot.slot_owner == slot_owner:
			return slot

	return null


func _get_all_slots(root: Node) -> Array[NewSlots]:
	var found: Array[NewSlots] = []
	_collect_slots(root, found)
	return found


func _collect_slots(node: Node, found: Array[NewSlots]) -> void:
	if node is NewSlots:
		found.append(node)

	for child in node.get_children():
		_collect_slots(child, found)
