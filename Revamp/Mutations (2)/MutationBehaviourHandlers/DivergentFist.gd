extends Mutation
class_name DivergentFist


func on_attack_sequence_started_context(
	runtime: MutationRuntime,
	_context: AttackContext
) -> void:
	if runtime == null:
		return

	runtime.trigger_visual()


func modify_attack_steps(
	_runtime: MutationRuntime,
	steps: Array[AttackStep]
) -> Array[AttackStep]:
	var copied_steps: Array[AttackStep] = []

	if steps.is_empty():
		var forward_step: AttackStep = AttackStep.new()
		forward_step.setup(
			AttackStep.FORWARD,
			MutationSource.BASE,
			null
		)
		steps.append(forward_step)

	for step: AttackStep in steps:
		if step == null:
			continue

		copied_steps.append(step)
		copied_steps.append(_copy_step(step))

	return copied_steps


func _copy_step(source_step: AttackStep) -> AttackStep:
	var new_step: AttackStep = AttackStep.new()

	new_step.setup(
		source_step.direction,
		MutationSource.MUTATION,
		self
	)

	return new_step
