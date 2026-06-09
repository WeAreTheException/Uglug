extends Node
class_name FlashFeedback

@export var target: CanvasItem
@export var flash_color: Color = Color.WHITE
var base_modulate: Color = Color.WHITE
var tween: Tween = null

func setup_feedback_root(_root: CardFeedbackRoot) -> void:
	if target != null:
		base_modulate = target.modulate

func play(time: float) -> void:
	if target == null:
		return
	_kill()
	tween = create_tween()
	tween.tween_property(target, "modulate", flash_color, time)
	tween.tween_property(target, "modulate", base_modulate, time)
	await tween.finished

func _kill() -> void:
	if tween != null:
		tween.kill()
		tween = null
