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

	var left_slot := _find_closest_slot_left_of(front_slot, enemy_slots)
	var right_slot := _find_closest_slot_right_of(front_slot, enemy_slots)

	if _card_attacks_left_to_right(card):
		_add_ordered_slot(left_slot)
		_add_ordered_slot(right_slot)
	else:
		_add_ordered_slot(right_slot)
		_add_ordered_slot(left_slot)

	for slot in ordered_adjacent_slots:
		_add_slot_or_direct(targets, slot)

	print("ANTLER front slot=", front_slot, " x=", front_slot.global_position.x)
	print("ANTLER left slot=", left_slot, " x=", left_slot.global_position.x if left_slot != null else "null")
	print("ANTLER right slot=", right_slot, " x=", right_slot.global_position.x if right_slot != null else "null")
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


func _find_closest_slot_left_of(center_slot: NewSlots, slots: Array[NewSlots]) -> NewSlots:
	var closest: NewSlots = null
	var closest_distance: float = INF
	var center_x: float = center_slot.global_position.x

	for slot in slots:
		if slot == null:
			continue

		if slot == center_slot:
			continue

		var slot_x: float = slot.global_position.x

		if slot_x >= center_x:
			continue

		var distance: float = abs(center_x - slot_x)

		if distance < closest_distance:
			closest_distance = distance
			closest = slot

	return closest


func _find_closest_slot_right_of(center_slot: NewSlots, slots: Array[NewSlots]) -> NewSlots:
	var closest: NewSlots = null
	var closest_distance: float = INF
	var center_x: float = center_slot.global_position.x

	for slot in slots:
		if slot == null:
			continue

		if slot == center_slot:
			continue

		var slot_x: float = slot.global_position.x

		if slot_x <= center_x:
			continue

		var distance: float = abs(center_x - slot_x)

		if distance < closest_distance:
			closest_distance = distance
			closest = slot

	return closest
