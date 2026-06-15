extends Area2D
class_name SigilInput

signal sigil_hovered(input: SigilInput)
signal sigil_unhovered(input: SigilInput)

signal sigil_left_pressed(input: SigilInput)
signal sigil_left_released(input: SigilInput)

signal sigil_right_pressed(input: SigilInput)
signal sigil_right_released(input: SigilInput)

var is_hovered: bool = false


func _ready() -> void:
	input_pickable = true
	monitoring = true
	monitorable = true

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)


func set_input_enabled(value: bool) -> void:
	input_pickable = value
	monitoring = value
	monitorable = value
	visible = value


func _on_mouse_entered() -> void:
	is_hovered = true
	sigil_hovered.emit(self)


func _on_mouse_exited() -> void:
	is_hovered = false
	sigil_unhovered.emit(self)


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton

	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		if mouse_event.pressed:
			sigil_left_pressed.emit(self)
		else:
			sigil_left_released.emit(self)

	if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		if mouse_event.pressed:
			sigil_right_pressed.emit(self)
		else:
			sigil_right_released.emit(self)
