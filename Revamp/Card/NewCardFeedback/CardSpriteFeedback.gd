extends Node
class_name CardSpriteFeedback

@export_group("Sprite References")
@export var ant_image_root: Node2D
@export var ant_image: CanvasItem
@export var ant_red_flash_overlay: CanvasItem

@export var print_debug: bool = true

var original_position: Vector2 = Vector2.ZERO
var original_scale: Vector2 = Vector2.ONE
var original_ant_self_modulate: Color = Color.WHITE

var active_tween: Tween = null
var flash_tween: Tween = null


func _ready() -> void:
	if ant_image_root != null:
		original_position = ant_image_root.position
		original_scale = ant_image_root.scale

	if ant_image != null:
		original_ant_self_modulate = ant_image.self_modulate

	if ant_red_flash_overlay != null:
		ant_red_flash_overlay.visible = false
		ant_red_flash_overlay.self_modulate = Color(1.0, 0.0, 0.0, 0.0)


func play_hurt_sprite_feedback(profile: CardFeedbackProfile) -> void:
	if ant_image_root == null:
		_debug_print("Missing ant_image_root.")
		return

	if profile == null:
		_debug_print("Missing hurt profile.")
		return

	_kill_active_tweens()

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		ant_image_root,
		"scale",
		original_scale * profile.scale_amount,
		profile.duration
	)

	active_tween.tween_property(
		ant_image_root,
		"position",
		original_position + profile.shake_amount,
		profile.duration * 0.5
	)

	_play_red_flash(profile)

	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		ant_image_root,
		"scale",
		original_scale,
		profile.return_duration
	)

	active_tween.tween_property(
		ant_image_root,
		"position",
		original_position,
		profile.return_duration
	)

	await active_tween.finished
	active_tween = null


func reset_sprite_feedback() -> void:
	_kill_active_tweens()

	if ant_image_root != null:
		ant_image_root.position = original_position
		ant_image_root.scale = original_scale

	if ant_image != null:
		ant_image.self_modulate = original_ant_self_modulate

	if ant_red_flash_overlay != null:
		ant_red_flash_overlay.visible = false
		ant_red_flash_overlay.self_modulate = Color(1.0, 0.0, 0.0, 0.0)


func _play_red_flash(profile: CardFeedbackProfile) -> void:
	if ant_red_flash_overlay != null:
		_play_overlay_red_flash(profile)
		return

	if ant_image != null:
		_play_self_modulate_red_flash(profile)


func _play_overlay_red_flash(profile: CardFeedbackProfile) -> void:
	if ant_red_flash_overlay == null:
		return

	if flash_tween != null:
		flash_tween.kill()

	ant_red_flash_overlay.visible = true
	ant_red_flash_overlay.self_modulate = Color(
		profile.flicker_color.r,
		profile.flicker_color.g,
		profile.flicker_color.b,
		0.0
	)

	flash_tween = create_tween()

	var safe_flicker_count: int = max(profile.flicker_count, 1)
	var flicker_step_duration: float = profile.duration / float(safe_flicker_count * 2)

	for i in safe_flicker_count:
		flash_tween.tween_property(
			ant_red_flash_overlay,
			"self_modulate",
			Color(
				profile.flicker_color.r,
				profile.flicker_color.g,
				profile.flicker_color.b,
				profile.flicker_color.a
			),
			flicker_step_duration
		)

		flash_tween.tween_property(
			ant_red_flash_overlay,
			"self_modulate",
			Color(
				profile.flicker_color.r,
				profile.flicker_color.g,
				profile.flicker_color.b,
				0.0
			),
			flicker_step_duration
		)

	await flash_tween.finished

	if ant_red_flash_overlay != null:
		ant_red_flash_overlay.visible = false


func _play_self_modulate_red_flash(profile: CardFeedbackProfile) -> void:
	if ant_image == null:
		return

	if flash_tween != null:
		flash_tween.kill()

	flash_tween = create_tween()

	var safe_flicker_count: int = max(profile.flicker_count, 1)
	var flicker_step_duration: float = profile.duration / float(safe_flicker_count * 2)

	for i in safe_flicker_count:
		flash_tween.tween_property(
			ant_image,
			"self_modulate",
			profile.flicker_color,
			flicker_step_duration
		)

		flash_tween.tween_property(
			ant_image,
			"self_modulate",
			original_ant_self_modulate,
			flicker_step_duration
		)


func _kill_active_tweens() -> void:
	if active_tween != null:
		active_tween.kill()
		active_tween = null

	if flash_tween != null:
		flash_tween.kill()
		flash_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardSpriteFeedback] ", message)
