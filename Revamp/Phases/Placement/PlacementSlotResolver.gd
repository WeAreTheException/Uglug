extends Node
class_name PlacementSlotResolver

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func get_default_slot(owner: SlotRow.SlotOwner) -> Slot:
	if controller == null:
		return null

	var board := controller.get_slots_root()

	if board == null:
		return null

	return board.get_first_empty_slot_in_order(
		owner,
		controller.get_left_to_right(owner)
	)


func is_valid_slot(slot: Slot, owner: SlotRow.SlotOwner) -> bool:
	if slot == null:
		return false

	if not slot.is_empty():
		return false

	if controller == null:
		return false

	var board := controller.get_slots_root()

	if board == null:
		return false

	return board.get_owner_of_slot(slot) == owner
