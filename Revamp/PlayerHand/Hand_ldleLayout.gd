extends Node
class_name Hand_IdleLayout

@export var card_spacing: float = 110.0
@export var move_time: float = 0.15

@export var curve_height: float = 40.0
@export var max_rotation_degrees: float = 12.0
@export var target_scale: Vector2 = Vector2.ONE

@export var hand_width_reference: float = 550.0
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
		var normalized_x := x_pos / hand_width_reference
		normalized_x = clampf(normalized_x, -1.0, 1.0)

		var y_pos := -(1.0 - normalized_x * normalized_x) * curve_height
		var rotation_deg := normalized_x * max_rotation_degrees

		_apply_card_layout(
			card,
			anchor_global_position + Vector2(x_pos, y_pos),
			rotation_deg,
			normal_z_start + i
		)


func _apply_card_layout(
	card: CardRoot,
	target_position: Vector2,
	target_rotation_degrees: float,
	z_value: int
) -> void:
	card.z_index = z_value

	var tween := card.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(card, "global_position", target_position, move_time)
	tween.parallel().tween_property(card, "rotation_degrees", target_rotation_degrees, move_time)
	tween.parallel().tween_property(card, "scale", target_scale, move_time)
