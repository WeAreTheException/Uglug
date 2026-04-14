extends Node2D
class_name DragHandler

static var selected_card: Card = null

var phase_manager: PhaseManager = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_into_slot_under_mouse()

func select_card(card: Card) -> void:
	if card == null:
		return

	if card.current_slot != null:
		print("select_card blocked: card already in slot")
		return

	if phase_manager != null:
		if card.card_owner != Card.Owner.PLAYER:
			print("select_card blocked: not player-owned card")
			return

		if not phase_manager.is_player_place_phase():
			print("select_card blocked: not in PLAYER_PLACE phase")
			return

	if DragHandler.selected_card != null and DragHandler.selected_card != card:
		DragHandler.selected_card.set_selected(false)

	if DragHandler.selected_card == card:
		unselect_current_card()
		return

	DragHandler.selected_card = card
	DragHandler.selected_card.set_selected(true)

	print("selected_card = ", DragHandler.selected_card.card_name)

func try_place_into_slot_under_mouse() -> void:
	if DragHandler.selected_card == null:
		return

	var space_state := get_viewport().world_2d.direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_viewport().get_mouse_position()
	params.collide_with_areas = true

	var results := space_state.intersect_point(params)

	for hit in results:
		var collider = hit.collider
		if collider is NewSlots:
			var slot: NewSlots = collider

			if phase_manager != null:
				if not phase_manager.is_player_place_phase():
					print("place blocked: not in PLAYER_PLACE phase")
					return

				if slot.slot_owner != NewSlots.SlotOwner.PLAYER:
					print("place blocked: not a player slot")
					return

			DragHandler.selected_card.place_into_slot(slot)
			DragHandler.selected_card.set_selected(false)
			DragHandler.selected_card = null
			return

func unselect_current_card() -> void:
	if DragHandler.selected_card == null:
		return

	DragHandler.selected_card.set_selected(false)
	DragHandler.selected_card = null
