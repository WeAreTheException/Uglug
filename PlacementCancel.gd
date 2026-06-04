extends Node
class_name PlacementCancel

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func cancel_placement(undo_pending_sacrifice: bool) -> void:
	if controller == null:
		return

	if controller.cleanup != null:
		controller.cleanup.clear_preview_feedback()

	var hand := controller.get_player_hand()

	if hand != null:
		hand.return_primed_card_to_prime_location()

	if controller.placement_state != null:
		controller.placement_state.reset()

	controller.set_hand_input_enabled(true)

	if undo_pending_sacrifice:
		controller.undo_pending_sacrifice()
