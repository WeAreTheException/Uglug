extends Node
class_name Hand_PlayLayout

@export var card_spacing: float = 150.0
@export var move_time: float = 0.15

@export var target_scale: Vector2 = Vector2(1.08, 1.08)
@export var normal_z_start: int = 0


func arrange_cards(cards: Array[CardRoot], anchor_global_position: Vector2) -> void:
	if cards.is_empty():
		return

	var total_width := card_spacing * float(cards.size() - 1)
	var start_x := -total_width / 2.0

	for i in range(cards.size()):
		var card := cards[i]

		if card == null:
			continue

		var x_pos := start_x + card_spacing * i

		_apply_card_layout(
			card,
			anchor_global_position + Vector2(x_pos, 0.0),
			normal_z_start + i
		)


func _apply_card_layout(
	card: CardRoot,
	target_position: Vector2,
	z_value: int
) -> void:
	card.z_index = z_value

	var tween := card.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(card, "global_position", target_position, move_time)
	tween.parallel().tween_property(card, "rotation_degrees", 0.0, move_time)
	tween.parallel().tween_property(card, "scale", target_scale, move_time)
