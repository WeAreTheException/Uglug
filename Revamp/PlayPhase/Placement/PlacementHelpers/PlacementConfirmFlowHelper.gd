extends RefCounted
class_name PlacementConfirmFlowHelper


func confirm(controller: PlacementController) -> void:
	if controller == null:
		return

	if not controller.is_placing():
		return

	if not controller.is_valid_placement_slot(controller.placement_state.preview_slot):
		controller.block("Invalid placement slot.")
		return

	controller.placement_state.is_confirming = true

	if controller.match_network_root != null:
		var payload := controller.build_current_placement_payload()

		if payload.is_empty():
			controller.placement_state.is_confirming = false
			controller.block("Placement payload failed.")
			return

		controller.match_network_root.request_placement(payload)

		if controller.print_debug:
			print("PLACEMENT REQUEST SENT: ", payload)

		controller.placement_state.is_confirming = false
		return

	var event := controller.placement_executor.confirm_placement(
		controller.placement_state.active_card,
		controller.placement_state.preview_slot,
		controller.placement_state.active_owner
	)

	if event.is_empty():
		controller.placement_state.is_confirming = false
		controller.block("Placement failed.")
		return

	controller.finish_flow.finish_placement(controller, event)
