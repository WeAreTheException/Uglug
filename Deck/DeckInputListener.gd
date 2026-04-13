extends Area2D
class_name DeckInputListener

var draw_handler: DeckDrawHandler = null

func _ready() -> void:
	input_pickable = true

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if draw_handler != null:
			draw_handler.draw_card()
