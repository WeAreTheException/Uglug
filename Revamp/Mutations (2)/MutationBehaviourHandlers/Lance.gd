extends Mutation
class_name Lance


func modify_attack_target(
	runtime: MutationRuntime,
	context: AttackContext
) -> void:
	if context == null:
		return

	if runtime != null:
		runtime.trigger_visual()

	context.carries_over_direct_damage = true
