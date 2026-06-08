extends Node
class_name SacrificePile

var cards: Array[CardRoot] = []


func add_card(card: CardRoot) -> void:
	if card != null:
		cards.append(card)


func count() -> int:
	return cards.size()


func get_cards() -> Array[CardRoot]:
	return cards.duplicate()
