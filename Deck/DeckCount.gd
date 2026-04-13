extends Node
class_name DeckCount

@export var total_cards: int = 5
@export var card_scene: PackedScene

func has_cards() -> bool:
	return total_cards > 0

func consume_card() -> bool:
	if total_cards <= 0:
		return false

	total_cards -= 1
	return true
