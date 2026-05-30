extends Node
class_name AttackSequencer

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"


func build_sequence(card: CardRoot) -> Array[String]:
	var sequence: Array[String] = []

	if card == null:
		return [FORWARD]

	var y_attack_count := _count_mutations(card, "Y Attack")
	var has_divergent_fist := _has_mutation(card, "Divergent Fist")

	# Base sequence
	if y_attack_count <= 0:
		sequence.append(FORWARD)
	else:
		for i in range(y_attack_count):
			sequence.append(LEFT)
			sequence.append(RIGHT)

	# Divergent Fist duplicates every attack event once
	if has_divergent_fist:
		var duplicated_sequence: Array[String] = []

		for attack_event in sequence:
			duplicated_sequence.append(attack_event)
			duplicated_sequence.append(attack_event)

		sequence = duplicated_sequence

	return sequence


func _has_mutation(card: CardRoot, mutation_name: String) -> bool:
	return _count_mutations(card, mutation_name) > 0


func _count_mutations(card: CardRoot, mutation_name: String) -> int:
	if card.mutations == null:
		return 0

	var count := 0

	for mutation in card.mutations.get_active_mutations():
		if mutation == null:
			continue

		if mutation.mutation_name == mutation_name:
			count += 1

	return count
