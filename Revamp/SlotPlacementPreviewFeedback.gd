extends Node
class_name SlotPlacementPreviewFeedback

@export var target: CanvasItem

@export var preview_alpha: float = 1.0
@export var idle_alpha: float = 0.75
@export var preview_color: Color = Color(0.4, 1.0, 1.0, 1.0)
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
		_apply_color(preview_color, preview_alpha)
	else:
		_apply_color(idle_color, idle_alpha)


func _apply_color(color: Color, alpha: float) -> void:
	if target == null:
		return

	if tween != null:
		tween.kill()

	var final_color := color
	final_color.a = alpha

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", final_color, tween_time)
