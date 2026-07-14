extends Area2D
class_name CardInput

signal hovered
signal unhovered
signal pressed(button_index: int)

var is_hovered: bool = false
var is_enabled: bool = true


func _ready() -> void:
	set_input_enabled(true)

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)


func set_input_enabled(value: bool) -> void:
	is_enabled = value
	input_pickable = value

	if not value and is_hovered:
		is_hovered = false
		unhovered.emit()


func _on_mouse_entered() -> void:
	if not is_enabled:
		return

	is_hovered = true
	hovered.emit()


func _on_mouse_exited() -> void:
	if not is_enabled:
		return

	is_hovered = false
	unhovered.emit()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_enabled:
		return

	if event is InputEventMouseButton:
		if event.pressed:
			pressed.emit(event.button_index)
