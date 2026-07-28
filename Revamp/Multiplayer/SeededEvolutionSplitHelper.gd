extends RefCounted
class_name SeededEvolutionSplitHelper


func split_mutations(
	mutations: Array[Mutation],
	seed_value: int
) -> Dictionary:
	var shuffled: Array[Mutation] = mutations.duplicate()
	var rng := RandomNumberGenerator.new()

	rng.seed = seed_value

	for i in range(shuffled.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, i)
		var temp: Mutation = shuffled[i]
		shuffled[i] = shuffled[swap_index]
		shuffled[swap_index] = temp

	var player_one_pile: Array[Mutation] = []
	var player_two_pile: Array[Mutation] = []
	var split_index: int = int(
		ceil(float(shuffled.size()) / 2.0)
	)

	for i in range(shuffled.size()):
		if i < split_index:
			player_one_pile.append(shuffled[i])
		else:
			player_two_pile.append(shuffled[i])

	return {
		"player_one_pile": player_one_pile,
		"player_two_pile": player_two_pile
	}
