extends Node
class_name SlotInput

signal clicked
signal hovered
signal unhovered

@export var click_area: Area2D

var slot: Slot = null
var is_hovered: bool = false
var was_left_down: bool = false


func setup(source_slot: Slot) -> void:
	slot = source_slot
	_connect_click_area()


func _ready() -> void:
	_connect_click_area()


func _process(_delta: float) -> void:
	var left_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if is_hovered and left_down and not was_left_down:
		_print_click("POLL")
		clicked.emit()

	was_left_down = left_down


func _connect_click_area() -> void:
	if click_area == null:
		print("SLOT INPUT BLOCKED: click_area null")
		return

	click_area.input_pickable = true

	if not click_area.input_event.is_connected(_on_click_area_input_event):
		click_area.input_event.connect(_on_click_area_input_event)

	if not click_area.mouse_entered.is_connected(_on_mouse_entered):
		click_area.mouse_entered.connect(_on_mouse_entered)

	if not click_area.mouse_exited.is_connected(_on_mouse_exited):
		click_area.mouse_exited.connect(_on_mouse_exited)


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_print_click("RAW")
			clicked.emit()


func _on_mouse_entered() -> void:
	is_hovered = true
	print(
		"SLOT INPUT HOVER | slot=",
		slot.name if slot != null else "null",
		" occupied=",
		slot.current_card != null if slot != null else false
	)
	hovered.emit()


func _on_mouse_exited() -> void:
	is_hovered = false
	print("SLOT INPUT UNHOVER | slot=", slot.name if slot != null else "null")
	unhovered.emit()


func _print_click(source: String) -> void:
	print(
		"SLOT INPUT ",
		source,
		" CLICK | slot=",
		slot.name if slot != null else "null",
		" occupied=",
		slot.current_card != null if slot != null else false,
		" card=",
		slot.current_card.card_name if slot != null and slot.current_card != null else "null"
	)
