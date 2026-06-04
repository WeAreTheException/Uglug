extends Node
class_name Hand_InputRouter

signal card_left_pressed(card: CardRoot)
signal card_left_released(card: CardRoot)
signal card_right_pressed(card: CardRoot)

var interaction_root: Hand_InteractionRoot = null
var pressed_card: CardRoot = null
var input_enabled: bool = true


func setup(source_interaction_root: Hand_InteractionRoot) -> void:
	interaction_root = source_interaction_root


func set_input_enabled(value: bool) -> void:
	input_enabled = value

	if not input_enabled:
		pressed_card = null


func _input(event: InputEvent) -> void:
	if not input_enabled:
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton

	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_mouse(mouse_event)

	if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
		_handle_right_mouse()


func _handle_left_mouse(event: InputEventMouseButton) -> void:
	if event.pressed:
		pressed_card = _get_top_hovered_card()

		if pressed_card != null:
			card_left_pressed.emit(pressed_card)

		return

	if pressed_card == null:
		return

	card_left_released.emit(pressed_card)
	pressed_card = null


func _handle_right_mouse() -> void:
	var card := _get_top_hovered_card()

	if card != null:
		card_right_pressed.emit(card)


func _get_top_hovered_card() -> CardRoot:
	if interaction_root == null:
		return null

	return interaction_root.get_top_hovered_card()
