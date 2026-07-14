extends Area2D
class_name CardInput

signal hovered
signal unhovered
signal pressed(button_index: int)

@export var collision_shape: CollisionShape2D

var is_hovered: bool = false
var is_enabled: bool = true

var was_left_down: bool = false
var was_right_down: bool = false


func _ready() -> void:
	_find_collision_shape()
	set_input_enabled(true)


func _process(_delta: float) -> void:
	if not is_enabled:
		return

	_update_manual_hover()
	_update_manual_click()


func set_input_enabled(value: bool) -> void:
	is_enabled = value
	input_pickable = value

	if not value and is_hovered:
		is_hovered = false
		unhovered.emit()


func _find_collision_shape() -> void:
	if collision_shape != null:
		return

	collision_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D


func _update_manual_hover() -> void:
	var hovering := _is_mouse_inside_shape()

	if hovering == is_hovered:
		return

	is_hovered = hovering

	if is_hovered:
		hovered.emit()
	else:
		unhovered.emit()


func _update_manual_click() -> void:
	var left_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var right_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	if is_hovered and left_down and not was_left_down:
		pressed.emit(MOUSE_BUTTON_LEFT)

	if is_hovered and right_down and not was_right_down:
		pressed.emit(MOUSE_BUTTON_RIGHT)

	was_left_down = left_down
	was_right_down = right_down


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
