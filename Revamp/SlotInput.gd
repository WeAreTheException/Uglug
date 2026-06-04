extends Node
class_name SlotInput

signal clicked
signal hovered
signal unhovered

@export var click_area: Area2D

var slot: Slot = null
var is_hovered: bool = false


func setup(source_slot: Slot) -> void:
	slot = source_slot
	_connect_click_area()


func _ready() -> void:
	_connect_click_area()


func _connect_click_area() -> void:
	if click_area == null:
		return

	click_area.input_pickable = true

	if not click_area.input_event.is_connected(_on_click_area_input_event):
		click_area.input_event.connect(_on_click_area_input_event)

	if not click_area.mouse_entered.is_connected(_on_mouse_entered):
		click_area.mouse_entered.connect(_on_mouse_entered)

	if not click_area.mouse_exited.is_connected(_on_mouse_exited):
		click_area.mouse_exited.connect(_on_mouse_exited)


func _on_click_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()


func _on_mouse_entered() -> void:
	is_hovered = true
	hovered.emit()


func _on_mouse_exited() -> void:
	is_hovered = false
	unhovered.emit()
