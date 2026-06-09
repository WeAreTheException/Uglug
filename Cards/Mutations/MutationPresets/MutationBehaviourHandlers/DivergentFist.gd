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


func modify_attack_steps(
	_runtime: MutationRuntime,
	steps: Array[AttackStep]
) -> Array[AttackStep]:
	var copied_steps: Array[AttackStep] = []

	if steps.is_empty():
		var forward_step := AttackStep.new()
		forward_step.setup(
			AttackStep.FORWARD,
			MutationSource.BASE,
			null
		)
		steps.append(forward_step)

	for step in steps:
		if step == null:
			continue

		copied_steps.append(step)
		copied_steps.append(_copy_step(step))

	return copied_steps


func _copy_step(source_step: AttackStep) -> AttackStep:
	var new_step := AttackStep.new()
	new_step.setup(
		source_step.direction,
		MutationSource.MUTATION,
		self
	)

	return new_step
