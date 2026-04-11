extends Area2D
class_name CardInputListener

signal hovered(card)
signal hovered_off(card)
signal pressed(card)
signal released(card)

var hand_position: Vector2

func _on_mouse_entered() -> void:
	hovered.emit(self)

func _on_mouse_exited() -> void:
	hovered_off.emit(self)

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressed.emit(self)
		else:
			released.emit(self)
