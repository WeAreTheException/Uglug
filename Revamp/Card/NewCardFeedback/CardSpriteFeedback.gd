extends Node
class_name CardSpriteFeedback

@export var ant_image_root: Node2D
@export var ant_image: CanvasItem
@export var print_debug: bool = true

var original_position: Vector2 = Vector2.ZERO
var original_scale: Vector2 = Vector2.ONE
var original_modulate: Color = Color.WHITE

var active_tween: Tween = null


func _ready() -> void:
	if ant_image_root != null:
		original_position = ant_image_root.position
		original_scale = ant_image_root.scale

	if ant_image != null:
		original_modulate = ant_image.modulate


func play_hurt_sprite_feedback(profile: CardFeedbackProfile) -> void:
	if ant_image_root == null:
		_debug_print("Missing ant_image_root.")
		return

	if profile == null:
		_debug_print("Missing hurt profile.")
		return

	_kill_active_tween()

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

	if ant_image != null:
		_play_red_flicker(profile)

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
	_kill_active_tween()

	if ant_image_root != null:
		ant_image_root.position = original_position
		ant_image_root.scale = original_scale

	if ant_image != null:
		ant_image.modulate = original_modulate


func _play_red_flicker(profile: CardFeedbackProfile) -> void:
	var flicker_tween := create_tween()

	for i in profile.flicker_count:
		flicker_tween.tween_property(
			ant_image,
			"modulate",
			profile.flicker_color,
			profile.duration / float(profile.flicker_count * 2)
		)

		flicker_tween.tween_property(
			ant_image,
			"modulate",
			original_modulate,
			profile.duration / float(profile.flicker_count * 2)
		)


func _kill_active_tween() -> void:
	if active_tween != null:
		active_tween.kill()
		active_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardSpriteFeedback] ", message)
