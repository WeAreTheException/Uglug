extends Node
class_name StatTextFeedback

@export var label: RichTextLabel
@export var stripe_label: RichTextLabel

@export_group("Idle Float")
@export var idle_enabled: bool = true
@export var vertical_float_height: float = 6.0
@export var vertical_float_time: float = 2.5
@export var horizontal_drift_amount: float = 2.0
@export var horizontal_drift_time: float = 4.0
@export var rotation_amount_degrees: float = 0.8
@export var rotation_time: float = 5.0
@export var breathing_scale_amount: float = 0.03
@export var breathing_scale_time: float = 2.5

@export_group("Buffed Animation")
@export var buff_jump_distance: float = 12.0
@export var buff_up_time: float = 0.08
@export var buff_top_pause_time: float = 0.09
@export var buff_pop_settle_time: float = 0.10
@export var buff_down_time: float = 0.24
@export var buff_neutral_scale: Vector2 = Vector2.ONE
@export var buff_up_scale: Vector2 = Vector2(1.2, 1.2)
@export var buff_top_pause_scale: Vector2 = Vector2(1.05, 1.05)
@export var buff_down_pop_scale: Vector2 = Vector2(1.25, 1.25)

@export_group("Debuffed Animation")
@export var debuff_squeeze_scale: Vector2 = Vector2(1.25, 0.65)
@export var debuff_return_scale: Vector2 = Vector2.ONE
@export var debuff_squeeze_time: float = 0.12
@export var debuff_number_hold_time: float = 0.08
@export var debuff_return_time: float = 0.18

@export_group("Shadow")
@export var shadow_color: Color = Color(0, 0, 0, 0.55)
@export var shadow_offset: Vector2i = Vector2i(2, 3)

@export var print_debug: bool = false

var start_position: Vector2 = Vector2.ZERO
var start_rotation: float = 0.0
var start_scale: Vector2 = Vector2.ONE
var start_modulate: Color = Color.WHITE

var time_passed: float = 0.0
var punch_scale: Vector2 = Vector2.ONE
var extra_offset: Vector2 = Vector2.ZERO

var displayed_value: int = 0
var has_value: bool = false

var motion_tween: Tween = null


func _ready() -> void:
	_cache_label()
	_cache_stripe_label()
	_apply_shadow()


func _process(delta: float) -> void:
	time_passed += delta
	_update_idle()


func set_value_instant(value: int) -> void:
	displayed_value = value
	has_value = true
	_set_text(str(value))


func play_value_change(old_value: int, new_value: int) -> void:
	if new_value > old_value:
		await play_buffed_value_change(old_value, new_value)
		return

	if new_value < old_value:
		await play_debuffed_value_change(old_value, new_value)
		return

	set_value_instant(new_value)


func play_buffed_value_change(old_value: int, new_value: int) -> void:
	if label == null:
		return

	_kill_motion_tween()

	displayed_value = old_value
	has_value = true
	_set_text(str(old_value))

	extra_offset = Vector2.ZERO
	punch_scale = buff_neutral_scale
	label.pivot_offset = label.size * 0.5
	_sync_stripe_to_label()

	motion_tween = create_tween()
	motion_tween.set_parallel(true)

	motion_tween.tween_property(
		self,
		"extra_offset",
		Vector2(0.0, -buff_jump_distance),
		buff_up_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	motion_tween.tween_property(
		self,
		"punch_scale",
		buff_up_scale,
		buff_up_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await motion_tween.finished

	motion_tween = create_tween()
	motion_tween.set_parallel(true)

	motion_tween.tween_property(
		self,
		"extra_offset",
		Vector2(0.0, -buff_jump_distance),
		buff_top_pause_time
	)

	motion_tween.tween_property(
		self,
		"punch_scale",
		buff_top_pause_scale,
		buff_top_pause_time
	)

	await motion_tween.finished

	displayed_value = new_value
	_set_text(str(new_value))
	punch_scale = buff_down_pop_scale
	_sync_stripe_to_label()

	motion_tween = create_tween()
	motion_tween.set_parallel(true)

	motion_tween.tween_property(
		self,
		"extra_offset",
		Vector2(0.0, -buff_jump_distance),
		buff_pop_settle_time
	)

	motion_tween.tween_property(
		self,
		"punch_scale",
		buff_top_pause_scale,
		buff_pop_settle_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await motion_tween.finished

	motion_tween = create_tween()
	motion_tween.set_parallel(true)

	motion_tween.tween_property(
		self,
		"extra_offset",
		Vector2.ZERO,
		buff_down_time
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	motion_tween.tween_property(
		self,
		"punch_scale",
		buff_neutral_scale,
		buff_down_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await motion_tween.finished

	extra_offset = Vector2.ZERO
	punch_scale = buff_neutral_scale
	motion_tween = null
	_sync_stripe_to_label()


func play_debuffed_value_change(old_value: int, new_value: int) -> void:
	if label == null:
		return

	_kill_motion_tween()

	displayed_value = old_value
	has_value = true
	_set_text(str(old_value))

	extra_offset = Vector2.ZERO
	punch_scale = Vector2.ONE
	label.pivot_offset = label.size * 0.5
	_sync_stripe_to_label()

	motion_tween = create_tween()

	motion_tween.tween_property(
		self,
		"punch_scale",
		debuff_squeeze_scale,
		debuff_squeeze_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	await motion_tween.finished

	displayed_value = new_value
	_set_text(str(new_value))
	punch_scale = debuff_squeeze_scale
	_sync_stripe_to_label()

	if debuff_number_hold_time > 0.0:
		await get_tree().create_timer(debuff_number_hold_time).timeout

	motion_tween = create_tween()

	motion_tween.tween_property(
		self,
		"punch_scale",
		debuff_return_scale,
		debuff_return_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await motion_tween.finished

	punch_scale = debuff_return_scale
	motion_tween = null
	_sync_stripe_to_label()


func _cache_label() -> void:
	if label == null:
		_debug_print("Missing label.")
		return

	start_position = label.position
	start_rotation = label.rotation
	start_scale = label.scale
	start_modulate = label.modulate
	label.pivot_offset = label.size * 0.5


func _cache_stripe_label() -> void:
	if stripe_label == null:
		return

	if label == null:
		return

	stripe_label.pivot_offset = label.pivot_offset
	_sync_stripe_to_label()


func _update_idle() -> void:
	if label == null:
		return

	if not idle_enabled:
		label.position = start_position + extra_offset
		label.rotation = start_rotation
		label.scale = start_scale * punch_scale
		_sync_stripe_to_label()
		return

	var vertical_wave := sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave := sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave := sin((time_passed / rotation_time) * TAU)
	var breathing_wave := sin((time_passed / breathing_scale_time) * TAU)

	var y_offset := vertical_wave * vertical_float_height
	var x_offset := horizontal_wave * horizontal_drift_amount
	var rotation_offset := deg_to_rad(rotation_wave * rotation_amount_degrees)
	var scale_multiplier := 1.0 + (breathing_wave * breathing_scale_amount)

	label.position = start_position + Vector2(x_offset, y_offset) + extra_offset
	label.rotation = start_rotation + rotation_offset
	label.scale = start_scale * scale_multiplier * punch_scale

	_sync_stripe_to_label()


func _set_text(new_text: String) -> void:
	if label != null:
		label.text = new_text

	if stripe_label != null:
		stripe_label.text = new_text


func _sync_stripe_to_label() -> void:
	if label == null:
		return

	if stripe_label == null:
		return

	stripe_label.text = label.text
	stripe_label.position = label.position
	stripe_label.rotation = label.rotation
	stripe_label.scale = label.scale
	stripe_label.size = label.size
	stripe_label.pivot_offset = label.pivot_offset
	stripe_label.modulate = Color.WHITE


func _apply_shadow() -> void:
	if label != null:
		label.add_theme_color_override("font_shadow_color", shadow_color)
		label.add_theme_constant_override("shadow_offset_x", shadow_offset.x)
		label.add_theme_constant_override("shadow_offset_y", shadow_offset.y)

	if stripe_label != null:
		stripe_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		stripe_label.add_theme_constant_override("shadow_offset_x", 0)
		stripe_label.add_theme_constant_override("shadow_offset_y", 0)


func _kill_motion_tween() -> void:
	if motion_tween != null:
		motion_tween.kill()
		motion_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[StatTextFeedback] ", message)
