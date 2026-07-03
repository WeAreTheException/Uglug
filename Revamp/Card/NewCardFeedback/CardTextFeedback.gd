extends Node
class_name CardTextFeedback

@export_group("Health Text Reference")
@export var health_label: RichTextLabel
@export var health_stripe_label: RichTextLabel

@export_group("Attack Text Reference")
@export var attack_label: RichTextLabel
@export var attack_stripe_label: RichTextLabel

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

@export_group("Shadow")
@export var shadow_color: Color = Color(0, 0, 0, 0.55)
@export var shadow_offset: Vector2i = Vector2i(2, 3)

@export var print_debug: bool = true

var health_start_position: Vector2 = Vector2.ZERO
var health_start_rotation: float = 0.0
var health_start_scale: Vector2 = Vector2.ONE
var health_start_modulate: Color = Color.WHITE

var attack_start_position: Vector2 = Vector2.ZERO
var attack_start_rotation: float = 0.0
var attack_start_scale: Vector2 = Vector2.ONE
var attack_start_modulate: Color = Color.WHITE

var time_passed: float = 0.0

var health_punch_scale: Vector2 = Vector2.ONE
var attack_punch_scale: Vector2 = Vector2.ONE
var attack_extra_offset: Vector2 = Vector2.ZERO

var health_punch_tween: Tween = null
var health_flicker_tween: Tween = null

var attack_punch_tween: Tween = null
var attack_motion_tween: Tween = null


func _ready() -> void:
	_cache_health_label()
	_cache_health_stripe_label()
	_cache_attack_label()
	_cache_attack_stripe_label()
	_apply_shadow()


func _process(delta: float) -> void:
	time_passed += delta

	_update_health_idle()
	_update_attack_idle()


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

	_set_health_text(str(old_health))

	play_health_punch(profile)
	_play_health_flicker(profile)

	await get_tree().create_timer(profile.delay_before_number_change).timeout

	_set_health_text(str(new_health))
	_sync_health_stripe_to_health()


func play_buffed_attack_feedback(
	old_attack: int,
	new_attack: int,
	profile: CardFeedbackProfile
) -> void:
	if attack_label == null:
		_debug_print("Missing attack_label.")
		return

	if profile == null:
		_debug_print("Missing buffed profile.")
		return

	_kill_attack_tweens()
	_hide_attack_stripe_during_animation()

	_set_attack_text(str(old_attack))
	attack_extra_offset = Vector2.ZERO
	attack_punch_scale = profile.buff_neutral_scale
	attack_label.pivot_offset = attack_label.size * 0.5

	_sync_attack_stripe_to_attack()
	_hide_attack_stripe_during_animation()

	await _play_attack_buff_up_down_value_change(old_attack, new_attack, profile)

	_hide_attack_stripe_during_animation()


func play_health_punch(profile: CardFeedbackProfile) -> void:
	if health_label == null:
		return

	if profile == null:
		return

	if health_punch_tween != null:
		health_punch_tween.kill()

	health_label.pivot_offset = health_label.size * 0.5
	health_punch_scale = profile.text_neutral_punch_scale

	health_punch_tween = create_tween()
	health_punch_tween.set_trans(Tween.TRANS_BACK)
	health_punch_tween.set_ease(Tween.EASE_OUT)

	health_punch_tween.tween_property(
		self,
		"health_punch_scale",
		profile.text_squash_scale,
		profile.text_squash_time
	)

	health_punch_tween.tween_property(
		self,
		"health_punch_scale",
		profile.text_stretch_scale,
		profile.text_stretch_time
	)

	health_punch_tween.tween_property(
		self,
		"health_punch_scale",
		profile.text_neutral_punch_scale,
		profile.text_return_time
	)


func reset_text_feedback() -> void:
	if health_punch_tween != null:
		health_punch_tween.kill()
		health_punch_tween = null

	if health_flicker_tween != null:
		health_flicker_tween.kill()
		health_flicker_tween = null

	if attack_punch_tween != null:
		attack_punch_tween.kill()
		attack_punch_tween = null

	if attack_motion_tween != null:
		attack_motion_tween.kill()
		attack_motion_tween = null

	health_punch_scale = Vector2.ONE
	attack_punch_scale = Vector2.ONE
	attack_extra_offset = Vector2.ZERO

	if health_label != null:
		health_label.position = health_start_position
		health_label.rotation = health_start_rotation
		health_label.scale = health_start_scale
		health_label.modulate = health_start_modulate

	if attack_label != null:
		attack_label.position = attack_start_position
		attack_label.rotation = attack_start_rotation
		attack_label.scale = attack_start_scale
		attack_label.modulate = attack_start_modulate

	_sync_health_stripe_to_health()
	_sync_attack_stripe_to_attack()
	_hide_attack_stripe_during_animation()


func _cache_health_label() -> void:
	if health_label == null:
		_debug_print("Missing health_label.")
		return

	health_start_position = health_label.position
	health_start_rotation = health_label.rotation
	health_start_scale = health_label.scale
	health_start_modulate = health_label.modulate
	health_label.pivot_offset = health_label.size * 0.5


func _cache_health_stripe_label() -> void:
	if health_stripe_label == null:
		return

	if health_label == null:
		return

	health_stripe_label.pivot_offset = health_label.pivot_offset
	_sync_health_stripe_to_health()


func _cache_attack_label() -> void:
	if attack_label == null:
		_debug_print("Missing attack_label.")
		return

	attack_start_position = attack_label.position
	attack_start_rotation = attack_label.rotation
	attack_start_scale = attack_label.scale
	attack_start_modulate = attack_label.modulate
	attack_label.pivot_offset = attack_label.size * 0.5


func _cache_attack_stripe_label() -> void:
	if attack_stripe_label == null:
		return

	if attack_label == null:
		return

	attack_stripe_label.pivot_offset = attack_label.pivot_offset
	_sync_attack_stripe_to_attack()
	_hide_attack_stripe_during_animation()


func _update_health_idle() -> void:
	if health_label == null:
		return

	if not idle_enabled:
		health_label.position = health_start_position
		health_label.rotation = health_start_rotation
		health_label.scale = health_start_scale * health_punch_scale

		_sync_health_stripe_to_health()
		return

	var vertical_wave := sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave := sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave := sin((time_passed / rotation_time) * TAU)
	var breathing_wave := sin((time_passed / breathing_scale_time) * TAU)

	var y_offset := vertical_wave * vertical_float_height
	var x_offset := horizontal_wave * horizontal_drift_amount
	var rotation_offset := deg_to_rad(rotation_wave * rotation_amount_degrees)
	var scale_multiplier := 1.0 + (breathing_wave * breathing_scale_amount)

	health_label.position = health_start_position + Vector2(x_offset, y_offset)
	health_label.rotation = health_start_rotation + rotation_offset
	health_label.scale = health_start_scale * scale_multiplier * health_punch_scale

	_sync_health_stripe_to_health()


func _update_attack_idle() -> void:
	if attack_label == null:
		return

	if not idle_enabled:
		attack_label.position = attack_start_position + attack_extra_offset
		attack_label.rotation = attack_start_rotation
		attack_label.scale = attack_start_scale * attack_punch_scale

		_sync_attack_stripe_to_attack()
		return

	var vertical_wave := sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave := sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave := sin((time_passed / rotation_time) * TAU)
	var breathing_wave := sin((time_passed / breathing_scale_time) * TAU)

	var y_offset := vertical_wave * vertical_float_height
	var x_offset := horizontal_wave * horizontal_drift_amount
	var rotation_offset := deg_to_rad(rotation_wave * rotation_amount_degrees)
	var scale_multiplier := 1.0 + (breathing_wave * breathing_scale_amount)

	attack_label.position = attack_start_position + Vector2(x_offset, y_offset) + attack_extra_offset
	attack_label.rotation = attack_start_rotation + rotation_offset
	attack_label.scale = attack_start_scale * scale_multiplier * attack_punch_scale

	_sync_attack_stripe_to_attack()


func _play_attack_buff_up_down_value_change(
	old_attack: int,
	new_attack: int,
	profile: CardFeedbackProfile
) -> void:
	if attack_label == null:
		return

	_set_attack_text(str(old_attack))
	attack_punch_scale = profile.buff_neutral_scale
	attack_extra_offset = Vector2.ZERO
	_sync_attack_stripe_to_attack()
	_hide_attack_stripe_during_animation()

	attack_motion_tween = create_tween()
	attack_motion_tween.set_parallel(true)

	attack_motion_tween.tween_property(
		self,
		"attack_extra_offset",
		Vector2(0.0, -profile.buff_jump_distance),
		profile.buff_up_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	attack_motion_tween.tween_property(
		self,
		"attack_punch_scale",
		profile.buff_up_scale,
		profile.buff_up_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await attack_motion_tween.finished

	attack_motion_tween = create_tween()
	attack_motion_tween.set_parallel(true)

	attack_motion_tween.tween_property(
		self,
		"attack_extra_offset",
		Vector2(0.0, -profile.buff_jump_distance),
		profile.buff_top_pause_time
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	attack_motion_tween.tween_property(
		self,
		"attack_punch_scale",
		profile.buff_top_pause_scale,
		profile.buff_top_pause_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await attack_motion_tween.finished

	_set_attack_text(str(new_attack))
	attack_punch_scale = profile.buff_down_pop_scale
	_sync_attack_stripe_to_attack()
	_hide_attack_stripe_during_animation()

	attack_motion_tween = create_tween()
	attack_motion_tween.set_parallel(true)

	attack_motion_tween.tween_property(
		self,
		"attack_extra_offset",
		Vector2(0.0, -profile.buff_jump_distance),
		profile.buff_pop_settle_time
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	attack_motion_tween.tween_property(
		self,
		"attack_punch_scale",
		profile.buff_top_pause_scale,
		profile.buff_pop_settle_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await attack_motion_tween.finished

	attack_motion_tween = create_tween()
	attack_motion_tween.set_parallel(true)

	attack_motion_tween.tween_property(
		self,
		"attack_extra_offset",
		Vector2.ZERO,
		profile.buff_down_time
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	attack_motion_tween.tween_property(
		self,
		"attack_punch_scale",
		profile.buff_neutral_scale,
		profile.buff_down_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await attack_motion_tween.finished

	attack_motion_tween = null
	_sync_attack_stripe_to_attack()
	_hide_attack_stripe_during_animation()


func _play_health_flicker(profile: CardFeedbackProfile) -> void:
	if health_label == null:
		return

	if health_flicker_tween != null:
		health_flicker_tween.kill()

	health_flicker_tween = create_tween()

	var safe_flicker_count: int = max(profile.flicker_count, 1)
	var flicker_step_duration: float = profile.duration / float(safe_flicker_count * 2)

	for i in safe_flicker_count:
		health_flicker_tween.tween_property(
			health_label,
			"modulate",
			profile.flicker_color,
			flicker_step_duration
		)

		health_flicker_tween.tween_property(
			health_label,
			"modulate",
			health_start_modulate,
			flicker_step_duration
		)


func _set_health_text(new_text: String) -> void:
	if health_label != null:
		health_label.text = new_text

	if health_stripe_label != null:
		health_stripe_label.text = new_text


func _set_attack_text(new_text: String) -> void:
	if attack_label != null:
		attack_label.text = new_text

	if attack_stripe_label != null:
		attack_stripe_label.text = new_text


func _sync_health_stripe_to_health() -> void:
	if health_label == null:
		return

	if health_stripe_label == null:
		return

	health_stripe_label.text = health_label.text
	health_stripe_label.position = health_label.position
	health_stripe_label.rotation = health_label.rotation
	health_stripe_label.scale = health_label.scale
	health_stripe_label.size = health_label.size
	health_stripe_label.pivot_offset = health_label.pivot_offset
	health_stripe_label.modulate = Color.WHITE


func _sync_attack_stripe_to_attack() -> void:
	if attack_label == null:
		return

	if attack_stripe_label == null:
		return

	attack_stripe_label.text = attack_label.text
	attack_stripe_label.position = attack_label.position
	attack_stripe_label.rotation = attack_label.rotation
	attack_stripe_label.scale = attack_label.scale
	attack_stripe_label.size = attack_label.size
	attack_stripe_label.pivot_offset = attack_label.pivot_offset
	attack_stripe_label.modulate = Color.WHITE


func _hide_attack_stripe_during_animation() -> void:
	if attack_stripe_label == null:
		return

	attack_stripe_label.visible = false


func _kill_attack_tweens() -> void:
	if attack_punch_tween != null:
		attack_punch_tween.kill()
		attack_punch_tween = null

	if attack_motion_tween != null:
		attack_motion_tween.kill()
		attack_motion_tween = null


func _apply_shadow() -> void:
	if health_label != null:
		health_label.add_theme_color_override("font_shadow_color", shadow_color)
		health_label.add_theme_constant_override("shadow_offset_x", shadow_offset.x)
		health_label.add_theme_constant_override("shadow_offset_y", shadow_offset.y)

	if health_stripe_label != null:
		health_stripe_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		health_stripe_label.add_theme_constant_override("shadow_offset_x", 0)
		health_stripe_label.add_theme_constant_override("shadow_offset_y", 0)

	if attack_label != null:
		attack_label.add_theme_color_override("font_shadow_color", shadow_color)
		attack_label.add_theme_constant_override("shadow_offset_x", shadow_offset.x)
		attack_label.add_theme_constant_override("shadow_offset_y", shadow_offset.y)

	if attack_stripe_label != null:
		attack_stripe_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		attack_stripe_label.add_theme_constant_override("shadow_offset_x", 0)
		attack_stripe_label.add_theme_constant_override("shadow_offset_y", 0)


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardTextFeedback] ", message)
