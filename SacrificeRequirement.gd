extends Node
class_name SacrificeRequirement


func get_current_worth(cards: Array[CardRoot]) -> int:
	var total := 0

	for card in cards:
		if card == null:
			continue

		total += card.get_sacrifice_worth()

	return total


func get_required_worth(primed_card: CardRoot) -> int:
	if primed_card == null:
		return 0

	return primed_card.get_sacrifice_cost()


func is_requirement_met(
	primed_card: CardRoot,
	cards: Array[CardRoot]
) -> bool:
	if primed_card == null:
		return false

	return get_current_worth(cards) >= get_required_worth(primed_card)
