extends Node
class_name PlacementCancel

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func cancel_placement(undo_pending_sacrifice: bool) -> void:
	if controller == null:
		return

	if controller.placement_preview != null:
		controller.placement_preview.clear_preview()

	var active_card: CardRoot = null

	if controller.placement_state != null:
		active_card = controller.placement_state.active_card
		controller.placement_state.is_confirming = true

	var hand := controller.get_player_hand()

	if hand != null:
		hand.clear_card_from_hand_layout_for_placement(active_card)

	if undo_pending_sacrifice:
		controller.undo_pending_sacrifice()

	if hand != null:
		hand.clear_play_selection_after_placement_cancel()

	if controller.placement_state != null:
		controller.placement_state.reset()

	controller.set_hand_input_enabled(true)
