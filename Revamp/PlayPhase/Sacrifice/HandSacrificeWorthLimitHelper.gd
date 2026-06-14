extends RefCounted
class_name HandSacrificeWorthLimitHelper


func would_over_select(
	card: CardRoot,
	primed_card: CardRoot,
	selected_cards: Array[CardRoot]
) -> bool:
	if card == null:
		return true

	if primed_card == null:
		return false

	var required_worth := primed_card.get_sacrifice_cost()

	if required_worth <= 0:
		return false

	var current_worth := get_selected_worth(selected_cards)
	var card_worth := card.get_sacrifice_worth()

	return current_worth + card_worth > required_worth


func get_selected_worth(selected_cards: Array[CardRoot]) -> int:
	var total := 0

	for card: CardRoot in selected_cards:
		if card == null:
			continue

		total += card.get_sacrifice_worth()

	return total
