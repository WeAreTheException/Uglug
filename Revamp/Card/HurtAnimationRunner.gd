extends Node
class_name HurtAnimationRunner

@export var left_distance: float = 10.0
@export var right_distance: float = 10.0

@export var down_distance: float = 6.0
@export var up_distance: float = 0.0

@export var horizontal_shake_time: float = 0.1
@export var vertical_shake_time: float = 0.1


func play(card: CardRoot) -> void:
	if card == null:
		return

	var start_pos: Vector2 = card.position

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		card,
		"position:x",
		start_pos.x - left_distance,
		horizontal_shake_time
	)

	tween.parallel().tween_property(
		card,
		"position:y",
		start_pos.y + down_distance,
		vertical_shake_time
	)

	tween.tween_property(
		card,
		"position:x",
		start_pos.x + right_distance,
		horizontal_shake_time
	)

	tween.parallel().tween_property(
		card,
		"position:y",
		start_pos.y - up_distance,
		vertical_shake_time
	)

	tween.tween_property(
		card,
		"position:x",
		start_pos.x,
		horizontal_shake_time
	)

	tween.parallel().tween_property(
		card,
		"position:y",
		start_pos.y,
		vertical_shake_time
	)

	await tween.finished
