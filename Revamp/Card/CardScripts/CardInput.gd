extends Area2D
class_name CardInput

signal hovered
signal unhovered
signal pressed
signal released


func _ready() -> void:
	input_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			pressed.emit()
		else:
			released.emit()


func _on_mouse_entered() -> void:
	hovered.emit()


func _on_mouse_exited() -> void:
	unhovered.emit()
