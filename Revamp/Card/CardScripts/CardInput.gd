extends Area2D
class_name CardInput

signal hovered
signal unhovered
signal pressed
signal released
signal right_pressed

var is_hovered: bool = false
var is_pressed: bool = false


func _ready() -> void:
	input_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_hovered:
					is_pressed = true
					pressed.emit()
			else:
				if is_pressed:
					is_pressed = false
					released.emit()

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and is_hovered:
				right_pressed.emit()


func _on_mouse_entered() -> void:
	is_hovered = true
	hovered.emit()


func _on_mouse_exited() -> void:
	is_hovered = false
	unhovered.emit()
