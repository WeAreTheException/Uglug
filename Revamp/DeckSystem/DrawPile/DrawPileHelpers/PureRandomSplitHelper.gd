extends RefCounted
class_name PureRandomSplitHelper

var shuffler := SeededShuffleHelper.new()


func split(cards: Array[CardData], seed_value: int) -> Dictionary:
	var shuffled := shuffler.shuffle_cards(cards, seed_value)
	var p1: Array[CardData] = []
	var p2: Array[CardData] = []
	for i in range(shuffled.size()):
		if i % 2 == 0:
			p1.append(shuffled[i])
		else:
			p2.append(shuffled[i])
	return {"p1": p1, "p2": p2}
