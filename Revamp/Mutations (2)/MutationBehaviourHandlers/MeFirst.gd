extends Mutation
class_name MeFirst

@export var priority_bonus: int = 100


func get_attack_priority(runtime: MutationRuntime) -> int:
	if runtime != null and priority_bonus != 0:
		runtime.trigger_visual()

	return priority_bonus
