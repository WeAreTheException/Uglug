extends Node2D
class_name HandLayout

@export var card_spacing: float = 110.0
@export var move_time: float = 0.15

@export var curve_height: float = 40.0
@export var max_rotation_degrees: float = 12.0
@export var hand_width_reference: float = 550.0

@export var normal_z_start: int = 0

var ignored_card: CardRoot = null


func arrange_cards(cards: Array[CardRoot]) -> void:
	if cards.is_empty():
		return

	var total_width := card_spacing * float(cards.size() - 1)
	var start_x := -total_width / 2.0

	for i in range(cards.size()):
		var card := cards[i]

		if card == null:
			continue

		if card == ignored_card:
			continue

		card.z_index = normal_z_start + i

		var x_pos := start_x + card_spacing * i

		var normalized_x := x_pos / hand_width_reference
		normalized_x = clampf(normalized_x, -1.0, 1.0)

		var y_pos := -(1.0 - normalized_x * normalized_x) * curve_height
		var rotation_deg := normalized_x * max_rotation_degrees

		var target_position := global_position + Vector2(x_pos, y_pos)

		var tween := card.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)

		tween.parallel().tween_property(card, "global_position", target_position, move_time)
		tween.parallel().tween_property(card, "rotation_degrees", rotation_deg, move_time)


func set_ignored_card(card: CardRoot) -> void:
	ignored_card = card


func clear_ignored_card() -> void:
	ignored_card = null


func get_insert_index_from_global_x(global_x: float, cards: Array[CardRoot]) -> int:
	if cards.is_empty():
		return 0

	var total_width := card_spacing * float(cards.size() - 1)
	var start_x := -total_width / 2.0
	var local_x := global_x - global_position.x

	var index := int(round((local_x - start_x) / card_spacing))

	return clampi(index, 0, cards.size() - 1)
