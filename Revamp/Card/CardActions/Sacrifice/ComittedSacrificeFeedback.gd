extends Node
class_name CommittedSacrificeFeedback

@export var target: CanvasItem
@export var committed_alpha: float = 0.0
@export var tween_time: float = 0.08

var sacrifice: Sacrifice = null
var tween: Tween = null


func setup(source_sacrifice: Sacrifice) -> void:
	sacrifice = source_sacrifice


func play(card: CardRoot) -> void:
	var target_item := _get_target(card)

	if target_item == null:
		return

	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		target_item,
		"modulate:a",
		committed_alpha,
		tween_time
	)


func _get_target(card: CardRoot) -> CanvasItem:
	if target != null:
		return target

	return card
