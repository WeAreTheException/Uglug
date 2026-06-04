extends Node
class_name SlotAttackPreviewFeedback

@export var target: CanvasItem

@export var preview_color: Color = Color(1.0, 0.3, 0.3, 0.55)
@export var idle_color: Color = Color(1.0, 1.0, 1.0, 0.75)

@export var tween_time: float = 0.08

var slot_feedback: SlotFeedback = null
var tween: Tween = null
var is_previewed: bool = false


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	set_previewed(false)


func set_previewed(value: bool) -> void:
	if is_previewed == value:
		return

	is_previewed = value

	if is_previewed:
		_apply_color(preview_color)
	else:
		_apply_color(idle_color)


func _apply_color(color: Color) -> void:
	if target == null:
		return

	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", color, tween_time)
