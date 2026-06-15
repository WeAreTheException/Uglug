extends RefCounted
class_name PlacementFinishFlowHelper


func finish_placement(
	controller: PlacementController,
	event: Dictionary
) -> void:
	if controller == null:
		return

	if event.is_empty():
		return

	var emitted_event := event.duplicate(true)

	if controller.placement_preview != null:
		controller.placement_preview.clear_preview()

	if controller.sacrifice_controller != null:
		controller.sacrifice_controller.commit_pending_sacrifice()

	if controller.event_emitter != null:
		controller.event_emitter.emit_card_placed(emitted_event)

	controller.card_placed.emit(emitted_event)
	controller.placement_finished.emit(emitted_event)

	if controller.placement_state != null:
		controller.placement_state.reset()

	controller.set_hand_input_enabled(true)

	if controller.slots_root != null:
		controller.slots_root.refresh_board_mutations()
