extends Node
class_name CardTextFeedback

@export_group("Health Text Reference")
@export var health_label: RichTextLabel

@export_group("Idle Levitate")
@export var idle_enabled: bool = true

@export var vertical_float_height: float = 6.0
@export var vertical_float_time: float = 2.5

@export var horizontal_drift_amount: float = 2.0
@export var horizontal_drift_time: float = 4.0

@export var rotation_amount_degrees: float = 0.8
@export var rotation_time: float = 5.0

@export_group("Breathing Scale")
@export var breathing_scale_amount: float = 0.03
@export var breathing_scale_time: float = 2.5

@export_group("Punch")
@export var squash_scale: Vector2 = Vector2(1.18, 0.72)
@export var stretch_scale: Vector2 = Vector2(0.88, 1.18)
@export var neutral_punch_scale: Vector2 = Vector2.ONE

@export var squash_time: float = 0.06
@export var stretch_time: float = 0.08
@export var return_time: float = 0.10

@export_group("Shadow")
@export var shadow_color: Color = Color(0, 0, 0, 0.55)
@export var shadow_offset: Vector2i = Vector2i(2, 3)

@export var print_debug: bool = true

var start_position: Vector2 = Vector2.ZERO
var start_rotation: float = 0.0
var start_scale: Vector2 = Vector2.ONE
var start_modulate: Color = Color.WHITE

var time_passed: float = 0.0
var punch_scale: Vector2 = Vector2.ONE

var punch_tween: Tween = null
var flicker_tween: Tween = null


func _ready() -> void:
	if health_label == null:
		_debug_print("Missing health_label.")
		return

	start_position = health_label.position
	start_rotation = health_label.rotation
	start_scale = health_label.scale
	start_modulate = health_label.modulate

	health_label.pivot_offset = health_label.size * 0.5

	_apply_shadow()


func _process(delta: float) -> void:
	if health_label == null:
		return

	if not idle_enabled:
		health_label.position = start_position
		health_label.rotation = start_rotation
		health_label.scale = start_scale * punch_scale
		return

	time_passed += delta

	var vertical_wave := sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave := sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave := sin((time_passed / rotation_time) * TAU)
	var breathing_wave := sin((time_passed / breathing_scale_time) * TAU)

	var y_offset := vertical_wave * vertical_float_height
	var x_offset := horizontal_wave * horizontal_drift_amount
	var rotation_offset := deg_to_rad(rotation_wave * rotation_amount_degrees)

	var scale_multiplier := 1.0 + (breathing_wave * breathing_scale_amount)

	health_label.position = start_position + Vector2(x_offset, y_offset)
	health_label.rotation = start_rotation + rotation_offset
	health_label.scale = start_scale * scale_multiplier * punch_scale


func play_hurt_health_feedback(
	old_health: int,
	new_health: int,
	profile: CardFeedbackProfile
) -> void:
	if health_label == null:
		_debug_print("Missing health_label.")
		return

	if profile == null:
		_debug_print("Missing profile.")
		return

	health_label.text = str(old_health)

	play_health_punch()
	_play_health_flicker(profile)

	await get_tree().create_timer(profile.delay_before_number_change).timeout

	health_label.text = str(new_health)


func play_health_punch() -> void:
	if health_label == null:
		return

	if punch_tween != null:
		punch_tween.kill()

	health_label.pivot_offset = health_label.size * 0.5
	punch_scale = neutral_punch_scale

	punch_tween = create_tween()
	punch_tween.set_trans(Tween.TRANS_BACK)
	punch_tween.set_ease(Tween.EASE_OUT)

	punch_tween.tween_property(self, "punch_scale", squash_scale, squash_time)
	punch_tween.tween_property(self, "punch_scale", stretch_scale, stretch_time)
	punch_tween.tween_property(self, "punch_scale", neutral_punch_scale, return_time)


func reset_text_feedback() -> void:
	if punch_tween != null:
		punch_tween.kill()
		punch_tween = null

	if flicker_tween != null:
		flicker_tween.kill()
		flicker_tween = null

	punch_scale = Vector2.ONE

	if health_label != null:
		health_label.position = start_position
		health_label.rotation = start_rotation
		health_label.scale = start_scale
		health_label.modulate = start_modulate


func _play_health_flicker(profile: CardFeedbackProfile) -> void:
	if health_label == null:
		return

	if flicker_tween != null:
		flicker_tween.kill()

	flicker_tween = create_tween()

	var safe_flicker_count: int = max(profile.flicker_count, 1)
	var flicker_step_duration: float = profile.duration / float(safe_flicker_count * 2)

	for i in safe_flicker_count:
		flicker_tween.tween_property(
			health_label,
			"modulate",
			profile.flicker_color,
			flicker_step_duration
		)

		flicker_tween.tween_property(
			health_label,
			"modulate",
			start_modulate,
			flicker_step_duration
		)


func _apply_shadow() -> void:
	if health_label == null:
		return

	health_label.add_theme_color_override("font_shadow_color", shadow_color)
	health_label.add_theme_constant_override("shadow_offset_x", shadow_offset.x)
	health_label.add_theme_constant_override("shadow_offset_y", shadow_offset.y)


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardTextFeedback] ", message)
