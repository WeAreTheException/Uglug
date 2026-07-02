extends Node
class_name CardVfxFeedback

@export var health_hurt_icon: Sprite2D

@export_group("Hurt Icon")
@export var test_key: Key = KEY_H
@export var start_scale: Vector2 = Vector2(1.0, 1.0)
@export var end_scale: Vector2 = Vector2(1.2, 1.2)
@export var start_alpha: float = 1.0
@export var end_alpha: float = 0.0
@export var pop_time: float = 0.05
@export var fade_time: float = 0.18

@export var enable_test_key: bool = false
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
		play_hurt_icon_feedback()


func play_hurt_icon_feedback() -> void:
	if health_hurt_icon == null:
		_debug_print("Missing health_hurt_icon.")
		return

	_kill_active_tween()

	health_hurt_icon.visible = true
	health_hurt_icon.position = start_position
	health_hurt_icon.scale = start_scale
	health_hurt_icon.self_modulate = Color(
		start_modulate.r,
		start_modulate.g,
		start_modulate.b,
		start_alpha
	)

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		health_hurt_icon,
		"scale",
		end_scale,
		pop_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		health_hurt_icon,
		"self_modulate",
		Color(
			start_modulate.r,
			start_modulate.g,
			start_modulate.b,
			end_alpha
		),
		fade_time
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
	health_hurt_icon.scale = start_scale
	health_hurt_icon.self_modulate = Color(
		start_modulate.r,
		start_modulate.g,
		start_modulate.b,
		end_alpha
	)


func _kill_active_tween() -> void:
	if active_tween != null:
		active_tween.kill()
		active_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardVfxFeedback] ", message)
