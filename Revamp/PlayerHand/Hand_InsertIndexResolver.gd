extends Node
class_name Hand_InsertIndexResolver


func get_insert_index(
	global_x: float,
	layout_cards: Array[CardRoot],
	anchor_global_position: Vector2,
	card_spacing: float
) -> int:
	if layout_cards.is_empty():
		return 0

	if card_spacing <= 0.0:
		return 0

	var total_width := card_spacing * float(layout_cards.size() - 1)
	var start_x := -total_width / 2.0
	var local_x := global_x - anchor_global_position.x

	var index := int(round((local_x - start_x) / card_spacing))

	return clampi(index, 0, layout_cards.size())
