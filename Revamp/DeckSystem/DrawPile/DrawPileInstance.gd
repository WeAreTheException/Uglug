extends Node
class_name DrawPileInstance

var cards: Array[CardData] = []


func set_cards(new_cards: Array[CardData]) -> void:
	cards = new_cards.duplicate()


func draw_card() -> CardData:
	if cards.is_empty():
		return null
	return cards.pop_front()


func cards_left() -> int:
	return cards.size()


func is_empty() -> bool:
	return cards.is_empty()


func get_cards_debug() -> Array[CardData]:
	return cards.duplicate()

func clear_cards() -> void:
	cards.clear()
