extends Node
class_name AttackSequencer

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"


func build_sequence(card: CardRoot) -> Array[String]:
	var sequence: Array[String] = []

	if card == null:
		return [FORWARD]

	if card.mutations == null:
		return [FORWARD]

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.add_attack_events(runtime, sequence)

	if sequence.is_empty():
		sequence.append(FORWARD)

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		sequence = runtime.mutation.modify_attack_sequence(runtime, sequence)

	return sequence
