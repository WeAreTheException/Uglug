extends Node
class_name DeckCount

const CARD_SCENE_PATH = "res://NewCard.tscn"

@export var total_cards: int = 5
var card_scene: PackedScene = preload(CARD_SCENE_PATH)

func has_cards() -> bool:
	return total_cards > 0

func consume_card() -> bool:
	if total_cards <= 0:
		return false

	total_cards -= 1
	return true
