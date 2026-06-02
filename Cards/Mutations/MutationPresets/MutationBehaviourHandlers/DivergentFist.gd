extends Mutation
class_name DivergentFist


func modify_attack_sequence(
	_runtime: MutationRuntime,
	sequence: Array[String]
) -> Array[String]:
	var new_sequence: Array[String] = []

	for attack_event in sequence:
		new_sequence.append(attack_event)
		new_sequence.append(attack_event)

	return new_sequence
