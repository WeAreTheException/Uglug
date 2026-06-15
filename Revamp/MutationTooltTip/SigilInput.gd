extends Area2D
class_name SigilInput

signal sigil_hovered(input: SigilInput)
signal sigil_unhovered(input: SigilInput)
signal sigil_right_clicked(input: SigilInput)
signal sigil_left_clicked(input: SigilInput)

@export var debug_enabled: bool = true
@export var show_debug_shape: bool = true
@export var debug_size: Vector2 = Vector2(40, 40)
@export var debug_color: Color = Color(0.0, 1.0, 0.0, 0.35)
@export var debug_hover_color: Color = Color(1.0, 1.0, 0.0, 0.5)

var is_hovered: bool = false


func _ready() -> void:
	input_pickable = true
	monitoring = true
	monitorable = true

	if debug_enabled:
		print("SIGIL INPUT READY: ", name)

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)

	queue_redraw()


func _draw() -> void:
	if not show_debug_shape:
		return

	var color := debug_color

	if is_hovered:
		color = debug_hover_color

	var rect := Rect2(-debug_size * 0.5, debug_size)
	draw_rect(rect, color, false, 2.0)


func set_input_enabled(value: bool) -> void:
	input_pickable = value
	monitoring = value
	monitorable = value
	visible = value
	queue_redraw()


func _on_mouse_entered() -> void:
	is_hovered = true
	sigil_hovered.emit(self)
	queue_redraw()

	if debug_enabled:
		print("SIGIL INPUT HOVERED: ", name)


func _on_mouse_exited() -> void:
	is_hovered = false
	sigil_unhovered.emit(self)
	queue_redraw()

	if debug_enabled:
		print("SIGIL INPUT UNHOVERED: ", name)


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton

	if not mouse_event.pressed:
		return

	if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		sigil_right_clicked.emit(self)

		if debug_enabled:
			print("SIGIL INPUT RIGHT CLICKED: ", name)

	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		sigil_left_clicked.emit(self)

		if debug_enabled:
			print("SIGIL INPUT LEFT CLICKED: ", name)
