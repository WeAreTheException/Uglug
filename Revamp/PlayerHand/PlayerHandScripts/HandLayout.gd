extends Node2D
class_name HandLayout

@export var card_spacing: float = 110.0
@export var move_time: float = 0.15


func arrange_cards(cards: Array[CardRoot]) -> void:
	print("HAND LAYOUT ARRANGE. cards = ", cards.size(), " layout pos = ", global_position)

	if cards.is_empty():
		return

	var total_width := card_spacing * float(cards.size() - 1)
	var start_x := -total_width / 2.0

	for i in range(cards.size()):
		var card := cards[i]

		if card == null:
			continue

		var target_position := global_position + Vector2(start_x + card_spacing * i, 0)

		print("MOVING CARD: ", card.card_name, " to ", target_position)

		var tween := card.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "global_position", target_position, move_time)
