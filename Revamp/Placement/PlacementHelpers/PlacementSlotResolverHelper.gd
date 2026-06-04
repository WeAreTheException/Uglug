extends RefCounted
class_name PlacementSlotResolverHelper


func get_default_slot(
	board: SlotsRoot,
	owner: SlotRow.SlotOwner,
	left_to_right: bool
) -> Slot:
	if board == null:
		return null

	return board.get_first_empty_slot_in_order(owner, left_to_right)
