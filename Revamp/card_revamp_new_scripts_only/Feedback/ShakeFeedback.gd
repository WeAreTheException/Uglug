extends Node
class_name ShakeFeedback

@export var target: Node2D
var base_position: Vector2 = Vector2.ZERO
var tween: Tween = null

func setup_feedback_root(_root: CardFeedbackRoot) -> void:
	if target != null:
		base_position = target.position

func play(distance: float, time: float, count: int) -> void:
	if target == null:
		return
	_kill()
	tween = create_tween()
	for i in range(count):
		tween.tween_property(target, "position:x", base_position.x - distance, time)
		tween.tween_property(target, "position:x", base_position.x + distance, time)
	tween.tween_property(target, "position", base_position, time)
	await tween.finished

func stop() -> void:
	_kill()
	if target != null:
		target.position = base_position

func _kill() -> void:
	if tween != null:
		tween.kill()
		tween = null
