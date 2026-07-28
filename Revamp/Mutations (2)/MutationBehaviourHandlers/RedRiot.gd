extends Mutation
class_name RedRiot


func can_intercept_direct_damage_context(
	_runtime: MutationRuntime,
	_context: DirectDamageContext
) -> bool:
	return true


func on_direct_damage_intercepted_context(
	runtime: MutationRuntime,
	_context: DirectDamageContext
) -> void:
	if runtime == null:
		return

	runtime.trigger_visual()
