extends Mutation
class_name DirectAttack


func modify_attack_target(
	runtime: MutationRuntime,
	context: AttackContext
) -> void:
	if context == null:
		return

	if runtime != null:
		runtime.trigger_visual()

	context.force_direct_damage = true
