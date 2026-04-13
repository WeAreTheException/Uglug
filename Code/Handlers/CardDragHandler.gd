extends Node2D
class_name CardDragHandler

var phase_manager: PhaseManager = null

var card_being_dragged: Card = null
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size

func _process(_delta: float) -> void:
	update_drag()

func update_drag() -> void:
	if card_being_dragged == null:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	card_being_dragged.global_position = Vector2(
		clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y)
	)

func start_drag(card: Card) -> void:
	if card == null:
		return

	if phase_manager == null:
		print("start_drag blocked: phase_manager is null")
		return

	if not phase_manager.is_player_place_phase():
		print("start_drag blocked: not in PLAYER_PLACE phase")
		return

	card_being_dragged = card
	card.scale = Vector2(1, 1)

	if card.current_slot != null:
		card.current_slot.clear_card()
		card.current_slot = null

	if card.player_hand != null:
		card.player_hand.remove_card_from_hand(card)

func stop_drag() -> Node2D:
	var card := card_being_dragged

	if card == null:
		return null

	card.scale = Vector2(1.05, 1.05)
	card_being_dragged = null

	if card.overlapping_slot != null:
		card.place_into_slot(card.overlapping_slot)
	else:
		card.return_to_hand()

	return card
