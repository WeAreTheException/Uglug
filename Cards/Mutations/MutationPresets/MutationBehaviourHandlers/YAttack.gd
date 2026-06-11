extends Mutation
class_name YAttack

@export var attack_left: bool = true
@export var attack_right: bool = true


func modify_attack_steps(
	_runtime: MutationRuntime,
	_steps: Array[AttackStep]
) -> Array[AttackStep]:
	var result: Array[AttackStep] = []

	if attack_left:
		result.append(_make_step(AttackStep.LEFT))

	if attack_right:
		result.append(_make_step(AttackStep.RIGHT))

	if result.is_empty():
		result.append(_make_step(AttackStep.FORWARD))

	return result


func _make_step(direction: String) -> AttackStep:
	var step := AttackStep.new()
	step.setup(direction, MutationSource.MUTATION, self)

	return step
