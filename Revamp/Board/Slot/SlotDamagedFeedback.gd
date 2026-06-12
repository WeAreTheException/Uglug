extends Node
class_name SlotDamagedFeedback

signal feedback_finished

@export var animated_target: Node2D
@export var feedback_delay: float = 0.08
@export var expand_scale: Vector2 = Vector2(1.16, 1.16)
@export var expand_time: float = 0.055
@export var return_time: float = 0.09

var slot_feedback: SlotFeedback = null
var active_tween: Tween = null
var base_scale: Vector2 = Vector2.ONE


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback

	var target := _get_target()

	if target != null:
		base_scale = target.scale


func play_feedback() -> void:
	var target := _get_target()

	if target == null:
		feedback_finished.emit()
		return

	if feedback_delay > 0.0:
		await get_tree().create_timer(feedback_delay).timeout

	if target == null or not is_instance_valid(target):
		feedback_finished.emit()
		return

	if active_tween != null:
		active_tween.kill()

	target.scale = base_scale

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_BACK)

	active_tween.set_ease(Tween.EASE_OUT)
	active_tween.tween_property(
		target,
		"scale",
		expand_scale,
		expand_time
	)

	active_tween.set_ease(Tween.EASE_IN)
	active_tween.tween_property(
		target,
		"scale",
		base_scale,
		return_time
	)

	await active_tween.finished

	active_tween = null
	feedback_finished.emit()


func _get_target() -> Node2D:
	if animated_target != null:
		return animated_target

	if slot_feedback != null:
		return slot_feedback.slot

	return null
