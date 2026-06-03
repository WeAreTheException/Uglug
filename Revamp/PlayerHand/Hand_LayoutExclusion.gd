extends Node
class_name Hand_LayoutExclusion

var ignored_card: CardRoot = null
var primed_card: CardRoot = null


func set_ignored_card(card: CardRoot) -> void:
	ignored_card = card


func clear_ignored_card() -> void:
	ignored_card = null


func set_primed_card(card: CardRoot) -> void:
	primed_card = card


func clear_primed_card() -> void:
	primed_card = null


func filter_cards(cards: Array[CardRoot]) -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	for card in cards:
		if card == null:
			continue

		if card == ignored_card:
			continue

		if card == primed_card:
			continue

		result.append(card)

	return result
