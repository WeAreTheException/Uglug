extends RefCounted
class_name PlacementStartFlowHelper


func start(controller: PlacementController, card: CardRoot, owner: SlotRow.SlotOwner) -> void:
	if card == null or controller.placement_state == null:
		controller.block("No card or missing PlacementState.")
		return

	controller.cancel_placement(false)
	controller.set_hand_input_enabled(false)
	controller.placement_state.start(card, owner)

	var hand := controller.get_player_hand()

	if hand != null:
		hand.lock_card_from_hand_layout_for_placement(card)

	var slot := controller.slot_resolver.get_default_slot(
		controller.slots_root,
		owner,
		controller.get_left_to_right(owner)
	)

	if slot == null:
		if hand != null:
			hand.clear_card_from_hand_layout_for_placement(card)

		controller.block("No empty placement slot.")
		controller.cancel_placement(true)
		return

	controller.request_preview_slot(slot)
	controller.placement_started.emit(card, slot)
