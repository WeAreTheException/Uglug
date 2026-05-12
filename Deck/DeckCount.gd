extends Node
class_name DeckCount

@export var card_database: CardDatabase
@export var card_scene: PackedScene

var real_deck: Array[CardData] = []


func build_real_deck() -> void:
	real_deck.clear()

	print("=== BUILDING REAL DECK ===")
	print("DeckCount node: ", name)
	print("card_database: ", card_database)

	if card_database == null:
		print("FAILED: card_database is null")
		return

	print("card_database.cards size: ", card_database.cards.size())

	for data in card_database.cards:
		if data == null:
			print("skipped null card data")
			continue

		print("adding card: ", data.name, " amount: ", data.deck_amount)

		for i in range(data.deck_amount):
			real_deck.append(data)

	real_deck.shuffle()

	print("FINAL real deck size: ", real_deck.size())
	print("==========================")
	

func has_cards() -> bool:
	return not real_deck.is_empty()


func cards_left() -> int:
	return real_deck.size()


func draw_card_data() -> CardData:
	if real_deck.is_empty():
		print("draw blocked: real deck empty")
		return null

	return real_deck.pop_back()
