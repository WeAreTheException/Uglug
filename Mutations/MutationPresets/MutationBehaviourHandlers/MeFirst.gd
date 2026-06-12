extends Mutation
class_name MeFirst

@export var priority_bonus: int = 100


func get_attack_priority(_runtime: MutationRuntime) -> int:
	return priority_bonus
