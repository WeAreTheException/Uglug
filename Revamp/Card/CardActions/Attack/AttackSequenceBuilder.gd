extends Node
class_name AttackSequencer

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"


func build_steps(card: CardRoot) -> Array[AttackStep]:
	return build_steps_with_order(card, true)


func build_steps_with_order(
	card: CardRoot,
	left_to_right: bool
) -> Array[AttackStep]:
	var steps: Array[AttackStep] = _get_base_steps(card)

	if not left_to_right:
		steps = _flip_side_steps(steps)

	return steps


func build_sequence(card: CardRoot) -> Array[String]:
	var result: Array[String] = []

	for step in build_steps(card):
		if step == null:
			continue

		result.append(step.direction)

	if result.is_empty():
		result.append(FORWARD)

	return result


func _get_base_steps(card: CardRoot) -> Array[AttackStep]:
	if card == null:
		return [_make_base_step(FORWARD)]

	if card.mutations == null:
		return [_make_base_step(FORWARD)]

	var steps: Array[AttackStep] = card.mutations.build_attack_steps()

	if steps.is_empty():
		steps.append(_make_base_step(FORWARD))

	return steps


func _flip_side_steps(steps: Array[AttackStep]) -> Array[AttackStep]:
	var result: Array[AttackStep] = []

	for step in steps:
		if step == null:
			continue

		result.append(_copy_step_with_flipped_direction(step))

	return result


func _copy_step_with_flipped_direction(source_step: AttackStep) -> AttackStep:
	var new_step := AttackStep.new()
	var direction: String = source_step.direction

	if direction == LEFT:
		direction = RIGHT
	elif direction == RIGHT:
		direction = LEFT

	new_step.setup(
		direction,
		source_step.source_type,
		source_step.source
	)

	return new_step


func _make_base_step(direction: String) -> AttackStep:
	var step := AttackStep.new()
	step.setup(direction, MutationSource.BASE, null)

	return step
