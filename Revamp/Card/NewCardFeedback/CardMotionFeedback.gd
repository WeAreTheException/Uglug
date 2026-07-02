extends Node
class_name CardMotionFeedback

@export_group("Target")
@export var motion_target: Node2D

@export var print_debug: bool = true

var original_position: Vector2 = Vector2.ZERO
var original_rotation: float = 0.0
var original_scale: Vector2 = Vector2.ONE

var active_tween: Tween = null


func _ready() -> void:
	if motion_target == null:
		return

	original_position = motion_target.position
	original_rotation = motion_target.rotation
	original_scale = motion_target.scale


func play_hurt_motion_feedback(profile: CardFeedbackProfile) -> void:
	if motion_target == null:
		_debug_print("Missing motion_target.")
		return

	if profile == null:
		_debug_print("Missing profile.")
		return

	_kill_active_tween()

	motion_target.position = original_position
	motion_target.rotation = original_rotation
	motion_target.scale = original_scale

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		motion_target,
		"position",
		original_position + profile.hurt_hit_offset,
		profile.hurt_hit_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		motion_target,
		"rotation",
		original_rotation + deg_to_rad(profile.hurt_hit_rotation_degrees),
		profile.hurt_hit_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		motion_target,
		"position",
		original_position + profile.hurt_recoil_offset,
		profile.hurt_recoil_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		motion_target,
		"rotation",
		original_rotation + deg_to_rad(profile.hurt_recoil_rotation_degrees),
		profile.hurt_recoil_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		motion_target,
		"position",
		original_position,
		profile.hurt_motion_return_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		motion_target,
		"rotation",
		original_rotation,
		profile.hurt_motion_return_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await active_tween.finished
	active_tween = null


func reset_motion_feedback() -> void:
	_kill_active_tween()

	if motion_target == null:
		return

	motion_target.position = original_position
	motion_target.rotation = original_rotation
	motion_target.scale = original_scale


func _kill_active_tween() -> void:
	if active_tween != null:
		active_tween.kill()
		active_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardMotionFeedback] ", message)
