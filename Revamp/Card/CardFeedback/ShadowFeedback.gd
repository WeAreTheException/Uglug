extends Node
class_name ShadowFeedback

@export var shadow_target: CanvasItem
@export var fade_time: float = 0.08
var tween: Tween = null

func setup_feedback_root(_root: CardFeedbackRoot) -> void:
	set_visible(false)

func set_visible(value: bool) -> void:
	if shadow_target == null:
		return
	shadow_target.visible = value

func fade_visible(value: bool) -> void:
	if shadow_target == null:
		return
	shadow_target.visible = true
	_kill()
	var alpha := 1.0 if value else 0.0
	tween = create_tween()
	tween.tween_property(shadow_target, "modulate:a", alpha, fade_time)
	await tween.finished
	if not value:
		shadow_target.visible = false

func _kill() -> void:
	if tween != null:
		tween.kill()
		tween = null
