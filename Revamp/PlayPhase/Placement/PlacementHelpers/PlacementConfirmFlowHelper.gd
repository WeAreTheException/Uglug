extends RefCounted
class_name PlacementConfirmFlowHelper

func confirm(controller: PlacementController) -> void:
	if not controller.is_placing():
		return
	if not controller.is_valid_placement_slot(controller.placement_state.preview_slot):
		controller.block("Invalid placement slot.")
		return
	controller.placement_state.is_confirming = true
	var event := controller.placement_executor.confirm_placement(
		controller.placement_state.active_card,
		controller.placement_state.preview_slot,
		controller.placement_state.active_owner
	)
	if event.is_empty():
		controller.placement_state.is_confirming = false
		controller.block("Placement failed.")
		return
	_finish(controller, event)

func _finish(controller: PlacementController, event: Dictionary) -> void:
	var emitted_event := event.duplicate(true)
	if controller.placement_preview != null:
		controller.placement_preview.clear_preview()
	if controller.sacrifice_controller != null:
		controller.sacrifice_controller.commit_pending_sacrifice()
	if controller.event_emitter != null:
		controller.event_emitter.emit_card_placed(emitted_event)
	controller.card_placed.emit(emitted_event)
	controller.placement_finished.emit(emitted_event)
	controller.placement_state.reset()
	controller.set_hand_input_enabled(true)
