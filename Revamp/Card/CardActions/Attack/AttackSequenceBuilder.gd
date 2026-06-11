extends Node
class_name AttackSequencer

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"


func build_steps(card: CardRoot) -> Array[AttackStep]:
	if card == null:
		return [_make_base_step(FORWARD)]

	if card.mutations == null:
		return [_make_base_step(FORWARD)]

	var steps := card.mutations.build_attack_steps()

	if steps.is_empty():
		steps.append(_make_base_step(FORWARD))

	return steps


func build_sequence(card: CardRoot) -> Array[String]:
	if card == null:
		return [FORWARD]

	if card.mutations == null:
		return [FORWARD]

	return card.mutations.build_attack_events()


func _make_base_step(direction: String) -> AttackStep:
	var step := AttackStep.new()
	step.setup(direction, MutationSource.BASE, null)

	return step
