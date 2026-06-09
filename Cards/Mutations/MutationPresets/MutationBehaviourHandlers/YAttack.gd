extends Mutation
class_name YAttack

@export var attack_left: bool = true
@export var attack_right: bool = true


func add_attack_events(
	_runtime: MutationRuntime,
	events: Array[String]
) -> void:
	if attack_left:
		events.append(AttackStep.LEFT)

	if attack_right:
		events.append(AttackStep.RIGHT)


func add_attack_steps(
	_runtime: MutationRuntime,
	steps: Array[AttackStep]
) -> void:
	if attack_left:
		steps.append(_make_step(AttackStep.LEFT))

	if attack_right:
		steps.append(_make_step(AttackStep.RIGHT))


func _make_step(direction: String) -> AttackStep:
	var step := AttackStep.new()
	step.setup(direction, MutationSource.MUTATION, self)
	return step
