extends Mutation
class_name DirectAttack


func modify_attack_target(
	_runtime: MutationRuntime,
	context: AttackContext
) -> void:
	if context == null:
		return

	context.force_direct_damage = true
