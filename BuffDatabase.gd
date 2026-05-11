extends Node
class_name BuffDatabase

@export var mutations: Array[Mutation] = []

func get_random_mutation() -> Mutation:
	if mutations.is_empty():
		return null

	return mutations.pick_random()
