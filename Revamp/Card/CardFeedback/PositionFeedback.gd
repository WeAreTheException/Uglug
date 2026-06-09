extends Node
class_name PositionFeedback

@export var target: Node2D
var base_position: Vector2 = Vector2.ZERO
var tween: Tween = null

func setup_feedback_root(_root: CardFeedbackRoot) -> void:
	if target != null:
		base_position = target.position

func tween_offset(offset: Vector2, time: float) -> void:
	if target == null:
		return
	_kill()
	tween = create_tween()
	tween.tween_property(target, "position", base_position + offset, time)
	await tween.finished

func reset(time: float = 0.08) -> void:
	if target == null:
		return
	_kill()
	tween = create_tween()
	tween.tween_property(target, "position", base_position, time)

func hard_reset() -> void:
	if target != null:
		_kill()
		target.position = base_position

func _kill() -> void:
	if tween != null:
		tween.kill()
		tween = null
