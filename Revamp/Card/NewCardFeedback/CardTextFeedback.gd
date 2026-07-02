extends Node
class_name CardTextFeedback

@export_group("Health References")
@export var health_root: Node2D
@export var health_label: RichTextLabel

@export_group("Idle Levitate")
@export var idle_enabled: bool = true
@export var vertical_float_height: float = 6.0
@export var vertical_float_time: float = 2.5
@export var horizontal_drift_amount: float = 2.0
@export var horizontal_drift_time: float = 4.0
@export var rotation_amount_degrees: float = 0.8
@export var rotation_time: float = 5.0

@export_group("Text Squish")
@export var squash_scale: Vector2 = Vector2(1.18, 0.72)
@export var stretch_scale: Vector2 = Vector2(0.88, 1.18)
@export var neutral_squish_scale: Vector2 = Vector2.ONE
@export var squash_time: float = 0.06
@export var stretch_time: float = 0.08
@export var squish_return_time: float = 0.10

@export_group("Shadow")
@export var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.55)
@export var shadow_offset: Vector2i = Vector2i(2, 3)

@export var print_debug: bool = true

var health_start_position: Vector2 = Vector2.ZERO
var health_start_rotation: float = 0.0
var health_start_scale: Vector2 = Vector2.ONE
var health_label_start_modulate: Color = Color.WHITE

var time_passed: float = 0.0

var idle_position_offset: Vector2 = Vector2.ZERO
var idle_rotation_offset: float = 0.0
var squish_scale: Vector2 = Vector2.ONE

var squish_tween: Tween = null
var flicker_tween: Tween = null


func _ready() -> void:
	if health_root != null:
		health_start_position = health_root.position
		health_start_rotation = health_root.rotation
		health_start_scale = health_root.scale

	if health_label != null:
		health_label_start_modulate = health_label.modulate
		_apply_shadow(health_label)


func _process(delta: float) -> void:
	_update_idle_offsets(delta)
	_apply_health_transform()


func play_hurt_health_feedback(
	old_health: int,
	new_health: int,
	profile: CardFeedbackProfile
) -> void:
	if health_root == null:
		_debug_print("Missing health_root.")
		return

	if health_label == null:
		_debug_print("Missing health_label.")
		return

	if profile == null:
		_debug_print("Missing profile.")
		return

	_kill_feedback_tweens()

	health_label.text = str(old_health)

	_play_health_squish()
	_play_health_flicker(profile)

	await get_tree().create_timer(profile.delay_before_number_change).timeout

	health_label.text = str(new_health)


func reset_text_feedback() -> void:
	_kill_feedback_tweens()

	idle_position_offset = Vector2.ZERO
	idle_rotation_offset = 0.0
	squish_scale = Vector2.ONE

	if health_root != null:
		health_root.position = health_start_position
		health_root.rotation = health_start_rotation
		health_root.scale = health_start_scale

	if health_label != null:
		health_label.modulate = health_label_start_modulate


func _update_idle_offsets(delta: float) -> void:
	if health_root == null:
		return

	if not idle_enabled:
		idle_position_offset = Vector2.ZERO
		idle_rotation_offset = 0.0
		return

	time_passed += delta

	var vertical_wave: float = sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave: float = sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave: float = sin((time_passed / rotation_time) * TAU)

	idle_position_offset = Vector2(
		horizontal_wave * horizontal_drift_amount,
		vertical_wave * vertical_float_height
	)

	idle_rotation_offset = deg_to_rad(rotation_wave * rotation_amount_degrees)


func _apply_health_transform() -> void:
	if health_root == null:
		return

	health_root.position = health_start_position + idle_position_offset
	health_root.rotation = health_start_rotation + idle_rotation_offset
	health_root.scale = health_start_scale * squish_scale


func _play_health_squish() -> void:
	if squish_tween != null:
		squish_tween.kill()

	squish_scale = neutral_squish_scale

	squish_tween = create_tween()
	squish_tween.set_trans(Tween.TRANS_BACK)
	squish_tween.set_ease(Tween.EASE_OUT)

	squish_tween.tween_property(
		self,
		"squish_scale",
		squash_scale,
		squash_time
	)

	squish_tween.tween_property(
		self,
		"squish_scale",
		stretch_scale,
		stretch_time
	)

	squish_tween.tween_property(
		self,
		"squish_scale",
		neutral_squish_scale,
		squish_return_time
	)


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
			health_label_start_modulate,
			flicker_step_duration
		)


func _kill_feedback_tweens() -> void:
	if squish_tween != null:
		squish_tween.kill()
		squish_tween = null

	if flicker_tween != null:
		flicker_tween.kill()
		flicker_tween = null


func _apply_shadow(label: RichTextLabel) -> void:
	label.add_theme_color_override("font_shadow_color", shadow_color)
	label.add_theme_constant_override("shadow_offset_x", shadow_offset.x)
	label.add_theme_constant_override("shadow_offset_y", shadow_offset.y)


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardTextFeedback] ", message)
