extends Node
class_name PositionFeedback

@export var default_time: float = 0.12

var card: CardRoot = null
var base_position: Vector2
var tween: Tween = null


func setup(source_card: CardRoot) -> void:
	card = source_card

	if card == null:
		return

	base_position = card.position


func move_to_offset(offset: Vector2, duration: float = -1.0) -> void:
	if card == null:
		return

	if tween != null:
		tween.kill()

	var move_time := default_time

	if duration >= 0.0:
		move_time = duration

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "position", base_position + offset, move_time)
