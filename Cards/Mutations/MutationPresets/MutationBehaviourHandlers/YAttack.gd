extends Mutation
class_name YAttack


func add_attack_events(
	_runtime: MutationRuntime,
	events: Array[String]
) -> void:
	events.append("LEFT")
	events.append("RIGHT")
