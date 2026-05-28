extends Node2D
class_name Slot

signal clicked(slot: Slot)

@export var slot_index: int = 1
@export var click_area: Area2D

var current_card: CardRoot = null


func _ready() -> void:
	if click_area == null:
		click_area = get_node("Area2D") as Area2D

	click_area.input_pickable = true
	click_area.input_event.connect(_on_click_area_input_event)


func _on_click_area_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)


func is_empty() -> bool:
	return current_card == null


func assign_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if current_card != null:
		return false

	current_card = card

	return true


func clear_card() -> void:
	current_card = null
