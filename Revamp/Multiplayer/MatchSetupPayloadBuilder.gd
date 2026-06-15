extends RefCounted
class_name MatchSetupPayloadBuilder


func build_payload(
	seed: int,
	p1_start: Array[CardData],
	p2_start: Array[CardData],
	p1_draw: Array[CardData],
	p2_draw: Array[CardData]
) -> Dictionary:
	return {
		"seed": seed,
		"p1_starting_hand": _build_card_entries(p1_start, "p1_start"),
		"p2_starting_hand": _build_card_entries(p2_start, "p2_start"),
		"p1_draw_pile": _build_card_entries(p1_draw, "p1_draw"),
		"p2_draw_pile": _build_card_entries(p2_draw, "p2_draw")
	}


func _build_card_entries(cards: Array[CardData], prefix: String) -> Array:
	var entries := []

	for i in range(cards.size()):
		var card_data := cards[i]

		if card_data == null:
			continue

		entries.append({
			"card_id": card_data.get_safe_card_id(),
			"runtime_id": _build_runtime_id(card_data, prefix, i)
		})

	return entries


func _build_runtime_id(
	card_data: CardData,
	prefix: String,
	index: int
) -> String:
	return prefix + "_" + card_data.get_safe_card_id() + "_" + str(index)
