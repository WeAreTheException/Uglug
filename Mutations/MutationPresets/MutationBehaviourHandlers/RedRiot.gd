extends Mutation
class_name RedRiot


func can_intercept_direct_damage_context(
	_runtime: MutationRuntime,
	_context: DirectDamageContext
) -> bool:
	return true
