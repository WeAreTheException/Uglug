extends RefCounted
class_name DeckPoolBuilderHelper


func build_pool(deck: DeckDefinition) -> Array[CardData]:
	var result: Array[CardData] = []
	if deck == null:
		return result
	for entry in deck.get_entries():
		if entry == null or not entry.is_valid():
			continue
		for i in range(entry.amount):
			result.append(entry.card_data)
	return result
