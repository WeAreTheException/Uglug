extends Node
class_name SlotInput

signal clicked
signal hovered
signal unhovered

@export var click_area: Area2D
@export var collision_shape: CollisionShape2D

var slot: Slot = null
var is_hovered: bool = false
var was_left_down: bool = false


func setup(source_slot: Slot) -> void:
	slot = source_slot
	_find_collision_shape()


func _ready() -> void:
	_find_collision_shape()


func _process(_delta: float) -> void:
	_update_manual_hover()
	_update_manual_click()


func _find_collision_shape() -> void:
	if collision_shape == null and click_area != null:
		collision_shape = click_area.get_node_or_null("CollisionShape2D") as CollisionShape2D


func _update_manual_hover() -> void:
	var hovering := _is_mouse_inside_shape()

	if hovering == is_hovered:
		return

	is_hovered = hovering

	if is_hovered:
		print(
			"SLOT INPUT HOVER | slot=",
			slot.name if slot != null else "null",
			" occupied=",
			slot.current_card != null if slot != null else false
		)
		hovered.emit()
	else:
		print("SLOT INPUT UNHOVER | slot=", slot.name if slot != null else "null")
		unhovered.emit()


func _update_manual_click() -> void:
	var left_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if is_hovered and left_down and not was_left_down:
		print(
			"SLOT INPUT CLICK | slot=",
			slot.name if slot != null else "null",
			" occupied=",
			slot.current_card != null if slot != null else false,
			" card=",
			slot.current_card.card_name if slot != null and slot.current_card != null else "null"
		)

		clicked.emit()

	was_left_down = left_down


func _is_mouse_inside_shape() -> bool:
	if collision_shape == null:
		return false

	if collision_shape.disabled:
		return false

	var shape := collision_shape.shape

	if shape == null:
		return false

	var mouse_pos := collision_shape.get_global_mouse_position()
	var local_pos := collision_shape.global_transform.affine_inverse() * mouse_pos

	if shape is RectangleShape2D:
		var rect := shape as RectangleShape2D
		var half_size := rect.size * 0.5

		return abs(local_pos.x) <= half_size.x and abs(local_pos.y) <= half_size.y

	if shape is CircleShape2D:
		var circle := shape as CircleShape2D
		return local_pos.length() <= circle.radius

	return false
