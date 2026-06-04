extends RefCounted
class_name HandDragStateHelper

var held_card: CardRoot = null
var dragged_card: CardRoot = null
var press_mouse_position: Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO
var last_insert_index: int = -1


func reset() -> void:
	held_card = null
	dragged_card = null
	press_mouse_position = Vector2.ZERO
	drag_offset = Vector2.ZERO
	last_insert_index = -1


func has_held_card() -> bool:
	return held_card != null


func has_dragged_card() -> bool:
	return dragged_card != null
