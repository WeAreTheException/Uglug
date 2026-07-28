extends Mutation
class_name YAttack

@export var attack_left: bool = true
@export var attack_right: bool = true


func on_attack_sequence_started_context(
	runtime: MutationRuntime,
	_context: AttackContext
) -> void:
	if runtime == null:
		return

	runtime.trigger_visual()


func replaces_base_attack_step(_runtime: MutationRuntime) -> bool:
	return true


func add_attack_steps(
	_runtime: MutationRuntime,
	steps: Array[AttackStep]
) -> void:
	if attack_left:
		steps.append(_make_step(AttackStep.LEFT))

	if attack_right:
		steps.append(_make_step(AttackStep.RIGHT))

	if not attack_left and not attack_right:
		steps.append(_make_step(AttackStep.FORWARD))


func _make_step(direction: String) -> AttackStep:
	var step := AttackStep.new()
	step.setup(direction, MutationSource.MUTATION, self)

	return step
