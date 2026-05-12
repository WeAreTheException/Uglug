extends Resource
class_name DominantDatabase

@export var dominants: Array[Dominant] = []

func get_dominant(index: int = 0) -> Dominant:
	if dominants.is_empty():
		return null

	if index < 0 or index >= dominants.size():
		return null

	return dominants[index]
