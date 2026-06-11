extends RefCounted
class_name PlacementSlotValidatorHelper


func is_valid_slot(
	board: SlotsRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner
) -> bool:
	if board == null:
		return false

	if slot == null:
		return false

	if not slot.is_empty():
		return false

	return board.get_owner_of_slot(slot) == owner
