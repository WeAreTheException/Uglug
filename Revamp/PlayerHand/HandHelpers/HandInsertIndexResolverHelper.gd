extends RefCounted
class_name HandInsertIndexResolverHelper


func get_insert_index_from_global_x(
	global_x: float,
	cards: Array[CardRoot],
	origin: Vector2,
	card_spacing: float,
	exclusion: HandLayoutExclusionHelper
) -> int:
	var layout_cards := _get_layout_cards(cards, exclusion)

	if layout_cards.is_empty():
		return 0

	var total_width := card_spacing * float(layout_cards.size() - 1)
	var start_x := -total_width / 2.0
	var local_x := global_x - origin.x
	var index := int(round((local_x - start_x) / card_spacing))

	return clampi(index, 0, layout_cards.size() - 1)


func _get_layout_cards(
	cards: Array[CardRoot],
	exclusion: HandLayoutExclusionHelper
) -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	for card in cards:
		if card == null:
			continue

		if exclusion != null and not exclusion.should_include(card):
			continue

		result.append(card)

	return result
