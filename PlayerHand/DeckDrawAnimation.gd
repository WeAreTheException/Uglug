extends Node
class_name DeckDrawAnimation

@export var card_width: float = 200
@export var default_card_move_speed: float = 0.1

func calculate_card_position(hand_global_position: Vector2, hand_size: int, index: int) -> Vector2:
	var total_width := (hand_size - 1) * card_width
	var x_offset := index * card_width - total_width / 2.0

	return hand_global_position + Vector2(x_offset, 0)

func animate_card_to_position(card: Node2D, new_position: Vector2, speed := -1.0) -> void:
	if speed < 0:
		speed = default_card_move_speed

	kill_card_tween(card)

	var tween := get_tree().create_tween()

	card.set_meta("move_tween", tween)

	tween.tween_property(card, "global_position", new_position, speed)

	tween.finished.connect(func():
		if card.has_meta("move_tween") and card.get_meta("move_tween") == tween:
			card.remove_meta("move_tween")
	)

func kill_card_tween(card: Node2D) -> void:
	if card.has_meta("move_tween"):
		var tween = card.get_meta("move_tween")

		if tween != null:
			tween.kill()

		card.remove_meta("move_tween")
