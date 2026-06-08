extends RefCounted
class_name SeededShuffleHelper


func shuffle_cards(cards: Array[CardData], seed_value: int) -> Array[CardData]:
	var result: Array[CardData] = cards.duplicate()
	var rng := RandomNumberGenerator.new()

	rng.seed = seed_value

	for i in range(result.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, i)
		var temp: CardData = result[i]
		result[i] = result[swap_index]
		result[swap_index] = temp

	return result
