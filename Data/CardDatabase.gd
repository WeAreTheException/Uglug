extends Node
class_name CardDatabase

@export var cards: Array[CardData]


func get_card_by_id(card_id: String) -> CardData:
	for card in cards:
		if card != null and card.get_safe_card_id() == card_id:
			return card
	return null


func get_cards_by_pile_type(pile_type: CardData.CardPileType) -> Array[CardData]:
	var result: Array[CardData] = []
	for card in cards:
		if card != null and card.pile_type == pile_type:
			result.append(card)
	return result
