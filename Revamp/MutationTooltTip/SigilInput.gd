extends Area2D
class_name SigilInput

signal sigil_hovered(input: SigilInput)
signal sigil_unhovered(input: SigilInput)
signal sigil_right_clicked(input: SigilInput)
signal sigil_left_clicked(input: SigilInput)

@export var print_debug: bool = true

var is_hovered: bool = false


func _ready() -> void:
	input_pickable = true

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)


func _on_mouse_entered() -> void:
	is_hovered = true
	sigil_hovered.emit(self)

	if print_debug:
		print("SIGIL HOVERED: ", name)


func _on_mouse_exited() -> void:
	is_hovered = false
	sigil_unhovered.emit(self)

	if print_debug:
		print("SIGIL UNHOVERED: ", name)


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

		if print_debug:
			print("SIGIL RIGHT CLICKED: ", name)

	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		sigil_left_clicked.emit(self)

		if print_debug:
			print("SIGIL LEFT CLICKED: ", name)
