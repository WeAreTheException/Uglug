extends Node
class_name PlacementInputRouter

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func handle_slot_hovered(slot: Slot) -> void:
	if controller == null:
		return

	if not controller.is_placing():
		return

	if not controller.is_valid_placement_slot(slot):
		return

	controller.placement_state.set_hovered_slot(slot)
	controller.request_preview_slot(slot)


func handle_slot_unhovered(slot: Slot) -> void:
	if controller == null:
		return

	if controller.placement_state.hovered_slot == slot:
		controller.placement_state.set_hovered_slot(null)


func handle_slot_clicked(slot: Slot) -> void:
	if controller == null:
		return

	if not controller.is_placing():
		return

	if not controller.is_valid_placement_slot(slot):
		return

	controller.request_preview_slot(slot)
	controller.confirm_placement()
