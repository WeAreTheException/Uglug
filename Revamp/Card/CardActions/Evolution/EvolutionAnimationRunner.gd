extends Node
class_name EvolutionAnimationRunner

signal animation_finished

@export_group("Rise")
@export var jump_height: float = 35.0
@export var peak_scale_multiplier: float = 1.12
@export var rise_duration: float = 0.14

@export_group("Landing")
@export var landing_offset: float = 5.0
@export var landing_scale_multiplier: float = 0.97
@export var fall_duration: float = 0.16
@export var settle_duration: float = 0.09

var visual_target: Node2D = null
var active_tween: Tween = null

var rest_position: Vector2 = Vector2.ZERO
var rest_scale: Vector2 = Vector2.ONE


func setup(target: Node2D) -> void:
	visual_target = target


func play() -> void:
	if visual_target == null:
		animation_finished.emit()
		return

	_stop_active_tween()

	rest_position = visual_target.position
	rest_scale = visual_target.scale

	var peak_position := rest_position + Vector2.UP * jump_height
	var peak_scale := rest_scale * peak_scale_multiplier

	var landing_position := rest_position + Vector2.DOWN * landing_offset
	var landing_scale := rest_scale * landing_scale_multiplier

	active_tween = create_tween()

	active_tween.tween_property(
		visual_target,
		"position",
		peak_position,
		rise_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	active_tween.parallel().tween_property(
		visual_target,
		"scale",
		peak_scale,
		rise_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		visual_target,
		"position",
		landing_position,
		fall_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	active_tween.parallel().tween_property(
		visual_target,
		"scale",
		landing_scale,
		fall_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	active_tween.tween_property(
		visual_target,
		"position",
		rest_position,
		settle_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	active_tween.parallel().tween_property(
		visual_target,
		"scale",
		rest_scale,
		settle_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	active_tween.tween_callback(_finish_animation)


func reset_animation() -> void:
	_stop_active_tween()


func _stop_active_tween() -> void:
	if active_tween == null:
		return

	if active_tween.is_valid():
		active_tween.kill()

	active_tween = null

	if visual_target != null:
		visual_target.position = rest_position
		visual_target.scale = rest_scale


func _finish_animation() -> void:
	if visual_target != null:
		visual_target.position = rest_position
		visual_target.scale = rest_scale

	active_tween = null
	animation_finished.emit()
