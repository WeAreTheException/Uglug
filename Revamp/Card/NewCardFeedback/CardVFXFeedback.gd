extends Node
class_name CardVfxFeedback

@export_group("Hurt Icon")
@export var health_hurt_icon: Sprite2D

@export var hurt_icon_start_scale: Vector2 = Vector2(0.35, 0.35)
@export var hurt_icon_pop_scale: Vector2 = Vector2(1.25, 1.25)
@export var hurt_icon_end_scale: Vector2 = Vector2(0.9, 0.9)

@export var hurt_icon_start_offset: Vector2 = Vector2(0.0, 8.0)
@export var hurt_icon_end_offset: Vector2 = Vector2(0.0, -10.0)

@export var appear_time: float = 0.06
@export var hold_time: float = 0.08
@export var fade_time: float = 0.16

@export var opacity_flicker_count: int = 3
@export var max_alpha: float = 1.0
@export var min_flicker_alpha: float = 0.35

@export var print_debug: bool = true

var hurt_icon_start_position: Vector2 = Vector2.ZERO
var hurt_icon_start_modulate: Color = Color.WHITE

var hurt_icon_tween: Tween = null


func _ready() -> void:
	if health_hurt_icon == null:
		return

	hurt_icon_start_position = health_hurt_icon.position
	hurt_icon_start_modulate = health_hurt_icon.self_modulate

	health_hurt_icon.visible = false
	health_hurt_icon.scale = hurt_icon_start_scale
	health_hurt_icon.position = hurt_icon_start_position + hurt_icon_start_offset
	health_hurt_icon.self_modulate = Color(
		hurt_icon_start_modulate.r,
		hurt_icon_start_modulate.g,
		hurt_icon_start_modulate.b,
		0.0
	)


func play_hurt_icon_feedback() -> void:
	if health_hurt_icon == null:
		_debug_print("Missing health_hurt_icon.")
		return

	_kill_hurt_icon_tween()

	health_hurt_icon.visible = true
	health_hurt_icon.scale = hurt_icon_start_scale
	health_hurt_icon.position = hurt_icon_start_position + hurt_icon_start_offset
	health_hurt_icon.self_modulate = Color(
		hurt_icon_start_modulate.r,
		hurt_icon_start_modulate.g,
		hurt_icon_start_modulate.b,
		0.0
	)

	hurt_icon_tween = create_tween()
	hurt_icon_tween.set_parallel(true)

	hurt_icon_tween.tween_property(
		health_hurt_icon,
		"scale",
		hurt_icon_pop_scale,
		appear_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	hurt_icon_tween.tween_property(
		health_hurt_icon,
		"position",
		hurt_icon_start_position,
		appear_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	hurt_icon_tween.tween_property(
		health_hurt_icon,
		"self_modulate",
		Color(
			hurt_icon_start_modulate.r,
			hurt_icon_start_modulate.g,
			hurt_icon_start_modulate.b,
			max_alpha
		),
		appear_time
	)

	await hurt_icon_tween.finished

	await _play_opacity_shift()

	await get_tree().create_timer(hold_time).timeout

	hurt_icon_tween = create_tween()
	hurt_icon_tween.set_parallel(true)

	hurt_icon_tween.tween_property(
		health_hurt_icon,
		"scale",
		hurt_icon_end_scale,
		fade_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	hurt_icon_tween.tween_property(
		health_hurt_icon,
		"position",
		hurt_icon_start_position + hurt_icon_end_offset,
		fade_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	hurt_icon_tween.tween_property(
		health_hurt_icon,
		"self_modulate",
		Color(
			hurt_icon_start_modulate.r,
			hurt_icon_start_modulate.g,
			hurt_icon_start_modulate.b,
			0.0
		),
		fade_time
	)

	await hurt_icon_tween.finished

	if health_hurt_icon != null:
		health_hurt_icon.visible = false

	hurt_icon_tween = null


func reset_vfx_feedback() -> void:
	_kill_hurt_icon_tween()

	if health_hurt_icon == null:
		return

	health_hurt_icon.visible = false
	health_hurt_icon.scale = hurt_icon_start_scale
	health_hurt_icon.position = hurt_icon_start_position + hurt_icon_start_offset
	health_hurt_icon.self_modulate = Color(
		hurt_icon_start_modulate.r,
		hurt_icon_start_modulate.g,
		hurt_icon_start_modulate.b,
		0.0
	)


func _play_opacity_shift() -> void:
	if health_hurt_icon == null:
		return

	var safe_count: int = max(opacity_flicker_count, 1)
	var step_time: float = appear_time / float(safe_count)

	for i in safe_count:
		if health_hurt_icon == null:
			return

		health_hurt_icon.self_modulate = Color(
			hurt_icon_start_modulate.r,
			hurt_icon_start_modulate.g,
			hurt_icon_start_modulate.b,
			min_flicker_alpha
		)

		await get_tree().create_timer(step_time).timeout

		if health_hurt_icon == null:
			return

		health_hurt_icon.self_modulate = Color(
			hurt_icon_start_modulate.r,
			hurt_icon_start_modulate.g,
			hurt_icon_start_modulate.b,
			max_alpha
		)

		await get_tree().create_timer(step_time).timeout


func _kill_hurt_icon_tween() -> void:
	if hurt_icon_tween != null:
		hurt_icon_tween.kill()
		hurt_icon_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardVfxFeedback] ", message)
