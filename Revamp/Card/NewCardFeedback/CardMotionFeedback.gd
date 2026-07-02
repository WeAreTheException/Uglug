extends Node
class_name CardMotionFeedback

@export_group("Target")
@export var motion_target: Node2D

@export_group("Hurt Hit Motion")
@export var hit_offset: Vector2 = Vector2(-12.0, 7.0)
@export var hit_rotation_degrees: float = -4.0
@export var hit_time: float = 0.055

@export var recoil_offset: Vector2 = Vector2(4.0, -2.0)
@export var recoil_rotation_degrees: float = 1.5
@export var recoil_time: float = 0.075

@export var return_time: float = 0.12

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


func play_hurt_motion_feedback() -> void:
	if motion_target == null:
		_debug_print("Missing motion_target.")
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
		original_position + hit_offset,
		hit_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		motion_target,
		"rotation",
		original_rotation + deg_to_rad(hit_rotation_degrees),
		hit_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		motion_target,
		"position",
		original_position + recoil_offset,
		recoil_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		motion_target,
		"rotation",
		original_rotation + deg_to_rad(recoil_rotation_degrees),
		recoil_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)

	active_tween.tween_property(
		motion_target,
		"position",
		original_position,
		return_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		motion_target,
		"rotation",
		original_rotation,
		return_time
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
