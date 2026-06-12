extends Mutation
class_name Lance


func modify_attack_target(
	_runtime: MutationRuntime,
	context: AttackContext
) -> void:
	if context == null:
		return

	context.carries_over_direct_damage = true
