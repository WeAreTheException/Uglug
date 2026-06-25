extends RichTextLabel

@export var enabled: bool = true

@export_group("Shadow")
@export var shadow_color: Color = Color(0, 0, 0, 0.55)
@export var shadow_offset: Vector2i = Vector2i(2, 3)

@export_group("Soft Float")
@export var vertical_float_height: float = 8.0
@export var vertical_float_time: float = 2.0

@export var horizontal_drift_amount: float = 2.0
@export var horizontal_drift_time: float = 3.5

@export var rotation_amount_degrees: float = 1.5
@export var rotation_time: float = 4.0

var start_position: Vector2
var start_rotation: float
var time_passed: float = 0.0


func _ready() -> void:
	start_position = position
	start_rotation = rotation

	pivot_offset = size * 0.5

	_apply_shadow()


func _process(delta: float) -> void:
	if not enabled:
		position = start_position
		rotation = start_rotation
		return

	time_passed += delta

	var vertical_wave := sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave := sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave := sin((time_passed / rotation_time) * TAU)

	var y_offset := vertical_wave * vertical_float_height
	var x_offset := horizontal_wave * horizontal_drift_amount
	var rotation_offset := deg_to_rad(rotation_wave * rotation_amount_degrees)

	position = start_position + Vector2(x_offset, y_offset)
	rotation = start_rotation + rotation_offset


func _apply_shadow() -> void:
	add_theme_color_override("font_shadow_color", shadow_color)
	add_theme_constant_override("shadow_offset_x", shadow_offset.x)
	add_theme_constant_override("shadow_offset_y", shadow_offset.y)
