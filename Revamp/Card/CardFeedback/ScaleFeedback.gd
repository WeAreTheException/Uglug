extends Node
class_name ScaleFeedback

@export var target: Node2D
var base_scale: Vector2 = Vector2.ONE
var tween: Tween = null

func setup_feedback_root(_root: CardFeedbackRoot) -> void:
	if target != null:
		base_scale = target.scale

func tween_to(scale: Vector2, time: float) -> void:
	if target == null:
		return
	_kill()
	tween = create_tween()
	tween.tween_property(target, "scale", scale, time)
	await tween.finished

func pulse(scale: Vector2, time: float) -> void:
	await tween_to(scale, time)
	await tween_to(base_scale, time)

func reset() -> void:
	if target != null:
		_kill()
		target.scale = base_scale

func _kill() -> void:
	if tween != null:
		tween.kill()
		tween = null
