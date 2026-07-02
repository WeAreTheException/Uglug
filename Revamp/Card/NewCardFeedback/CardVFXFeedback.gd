extends Node
class_name CardVfxFeedback

@export var health_hurt_icon: Sprite2D

@export var enable_test_key: bool = false
@export var test_key: Key = KEY_H
@export var test_profile: CardFeedbackProfile

@export var print_debug: bool = true

var start_position: Vector2 = Vector2.ZERO
var start_modulate: Color = Color.WHITE

var active_tween: Tween = null


func _ready() -> void:
	if health_hurt_icon == null:
		return

	start_position = health_hurt_icon.position
	start_modulate = health_hurt_icon.self_modulate

	_hide_hurt_icon()


func _unhandled_input(event: InputEvent) -> void:
	if not enable_test_key:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed:
		return

	if key_event.echo:
		return

	if key_event.keycode == test_key:
		play_hurt_icon_feedback(test_profile)


func play_hurt_icon_feedback(profile: CardFeedbackProfile) -> void:
	if health_hurt_icon == null:
		_debug_print("Missing health_hurt_icon.")
		return

	if profile == null:
		_debug_print("Missing profile.")
		return

	_kill_active_tween()

	health_hurt_icon.visible = true
	health_hurt_icon.position = start_position
	health_hurt_icon.scale = profile.hurt_icon_start_scale
	health_hurt_icon.self_modulate = Color(
		start_modulate.r,
		start_modulate.g,
		start_modulate.b,
		profile.hurt_icon_start_alpha
	)

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		health_hurt_icon,
		"scale",
		profile.hurt_icon_end_scale,
		profile.hurt_icon_pop_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		health_hurt_icon,
		"self_modulate",
		Color(
			start_modulate.r,
			start_modulate.g,
			start_modulate.b,
			profile.hurt_icon_end_alpha
		),
		profile.hurt_icon_fade_time
	)

	await active_tween.finished

	_hide_hurt_icon()
	active_tween = null


func reset_vfx_feedback() -> void:
	_kill_active_tween()
	_hide_hurt_icon()


func _hide_hurt_icon() -> void:
	if health_hurt_icon == null:
		return

	health_hurt_icon.visible = false
	health_hurt_icon.position = start_position
	health_hurt_icon.self_modulate = Color(
		start_modulate.r,
		start_modulate.g,
		start_modulate.b,
		0.0
	)


func _kill_active_tween() -> void:
	if active_tween != null:
		active_tween.kill()
		active_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardVfxFeedback] ", message)
