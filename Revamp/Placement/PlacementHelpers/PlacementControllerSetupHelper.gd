extends RefCounted
class_name PlacementControllerSetupHelper


func setup_children(controller: PlacementController) -> void:
	for child in [
		controller.placement_state,
		controller.input_router,
		controller.placement_preview,
		controller.placement_executor,
		controller.event_emitter,
		controller.placement_cancel
	]:
		if child != null and child.has_method("setup"):
			child.setup(controller)


func connect_external_signals(controller: PlacementController) -> void:
	if controller.slots_root != null and controller.input_router != null:
		_connect(controller.slots_root.slot_hovered, controller.input_router.handle_slot_hovered)
		_connect(controller.slots_root.slot_unhovered, controller.input_router.handle_slot_unhovered)
		_connect(controller.slots_root.slot_clicked, controller.input_router.handle_slot_clicked)

	if controller.sacrifice_controller != null:
		_connect(
			controller.sacrifice_controller.pending_sacrifice_started,
			Callable(controller, "_on_pending_sacrifice_started")
		)
		_connect(
			controller.sacrifice_controller.pending_sacrifice_undone,
			Callable(controller, "_on_pending_sacrifice_undone")
		)

	if controller.player_hand != null:
		_connect(controller.player_hand.card_unprimed, Callable(controller, "_on_card_unprimed"))


func _connect(source_signal: Signal, target: Callable) -> void:
	if not source_signal.is_connected(target):
		source_signal.connect(target)
