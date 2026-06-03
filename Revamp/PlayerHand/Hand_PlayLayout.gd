extends Node
class_name Hand_PlayLayout

@export var card_spacing: float = 150.0
@export var move_time: float = 0.15

@export var target_scale: Vector2 = Vector2(1.08, 1.08)
@export var normal_z_start: int = 0


func arrange_cards(
	cards: Array[CardRoot],
	anchor_global_position: Vector2,
	layout_tweener: Hand_LayoutTweener
) -> void:
	if cards.is_empty():
		return

	var total_width := card_spacing * float(cards.size() - 1)
	var start_x := -total_width / 2.0

	for i in range(cards.size()):
		var card := cards[i]

		if card == null:
			continue

		var x_pos := start_x + card_spacing * i
		var target_position := anchor_global_position + Vector2(x_pos, 0.0)

		if layout_tweener != null:
			layout_tweener.tween_card(
				card,
				target_position,
				0.0,
				target_scale,
				normal_z_start + i,
				move_time
			)
		else:
			_apply_card_immediate(card, target_position, normal_z_start + i)


func _apply_card_immediate(
	card: CardRoot,
	target_position: Vector2,
	z_value: int
) -> void:
	card.z_index = z_value
	card.global_position = target_position
	card.rotation_degrees = 0.0
	card.scale = target_scale
