extends Node
class_name SlotPlayPhaseFeedback

@export var target: Node2D

@export var idle_scale: Vector2 = Vector2.ONE
@export var playable_scale: Vector2 = Vector2(1.08, 1.08)
@export var inactive_scale: Vector2 = Vector2(0.92, 0.92)

@export var idle_alpha: float = 1.0
@export var playable_alpha: float = 1.0
@export var inactive_alpha: float = 0.55

@export var tween_time: float = 0.12

var slot_feedback: SlotFeedback = null
var tween: Tween = null


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	show_idle()


func show_idle() -> void:
	_apply_feedback(idle_scale, idle_alpha)


func show_playable() -> void:
	_apply_feedback(playable_scale, playable_alpha)


func show_inactive() -> void:
	_apply_feedback(inactive_scale, inactive_alpha)


func _apply_feedback(target_scale: Vector2, target_alpha: float) -> void:
	if target == null:
		return

	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(target, "scale", target_scale, tween_time)

	if target is CanvasItem:
		tween.parallel().tween_property(
			target,
			"modulate:a",
			target_alpha,
			tween_time
		)
