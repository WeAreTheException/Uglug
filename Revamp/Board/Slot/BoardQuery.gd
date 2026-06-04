extends Node
class_name BoardQuery

var registry: BoardSlotRegistry = null


func setup(source_registry: BoardSlotRegistry) -> void:
	registry = source_registry


func get_slots_for_owner(owner: SlotRow.SlotOwner) -> Array[Slot]:
	if registry == null:
		return []

	return registry.get_slots_for_owner(owner)


func get_all_slots() -> Array[Slot]:
	if registry == null:
		return []

	return registry.get_all_slots()


func get_empty_slots_for_owner(owner: SlotRow.SlotOwner) -> Array[Slot]:
	var result: Array[Slot] = []

	for slot in get_slots_for_owner(owner):
		if slot != null and slot.is_empty():
			result.append(slot)

	return result


func get_slot(owner: SlotRow.SlotOwner, slot_index: int) -> Slot:
	for slot in get_slots_for_owner(owner):
		if slot != null and slot.slot_index == slot_index:
			return slot

	return null


func get_owner_of_slot(slot: Slot) -> SlotRow.SlotOwner:
	if registry == null:
		return SlotRow.SlotOwner.PLAYER

	if registry.is_opponent_slot(slot):
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER


func get_opposing_slot(slot: Slot) -> Slot:
	if slot == null:
		return null

	var enemy_owner := get_enemy_owner(get_owner_of_slot(slot))
	return get_slot(enemy_owner, slot.slot_index)


func get_adjacent_enemy_slots(slot: Slot) -> Array[Slot]:
	var result: Array[Slot] = []

	if slot == null:
		return result

	var enemy_owner := get_enemy_owner(get_owner_of_slot(slot))

	var left := get_slot(enemy_owner, slot.slot_index - 1)
	var right := get_slot(enemy_owner, slot.slot_index + 1)

	if left != null:
		result.append(left)

	if right != null:
		result.append(right)

	return result


func get_first_empty_slot_in_order(
	owner: SlotRow.SlotOwner,
	left_to_right: bool
) -> Slot:
	var slots := get_slots_for_owner(owner)

	if not left_to_right:
		slots.reverse()

	for slot in slots:
		if slot != null and slot.is_empty():
			return slot

	return null


func get_enemy_owner(owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER
