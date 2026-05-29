extends Node
class_name ScaleFeedback

@export var default_time: float = 0.12

var card: CardRoot = null
var base_scale: Vector2
var tween: Tween = null


func setup(source_card: CardRoot) -> void:
	card = source_card

	if card == null:
		return

	base_scale = card.scale


func scale_to(
	scale_multiplier: Vector2,
	duration: float = -1.0
) -> void:
	if card == null:
		return

	if tween != null:
		tween.kill()

	var scale_time := default_time

	if duration >= 0.0:
		scale_time = duration

	tween = create_tween()

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		card,
		"scale",
		base_scale * scale_multiplier,
		scale_time
	)
