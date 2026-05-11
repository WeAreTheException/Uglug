extends Mutation
class_name PregnAnt

@export var spawn_count: int = 2

func on_death(card: Card) -> void:
	if card == null:
		return

	var inheritance_handler := find_mutation_inheritance_handler(card)

	if inheritance_handler == null:
		print("PregnAnt blocked: could not find MutationInhertitanceHandler")
		return

	var inherited_mutation_paths: Array[String] = []

	for mutation in card.additional_mutations:
		if mutation == null:
			continue

		if mutation.resource_path == "":
			print("PregnAnt skipped inherited mutation because resource_path is empty")
			continue

		inherited_mutation_paths.append(mutation.resource_path)

	inheritance_handler.spawn_workers_with_mutations(
		card.owning_peer_id,
		spawn_count,
		inherited_mutation_paths
	)

func find_mutation_inheritance_handler(card: Card) -> MutationInhertitanceHandler:
	var scene := card.get_tree().current_scene

	if scene == null:
		return null

	return find_mutation_inheritance_handler_recursive(scene)

func find_mutation_inheritance_handler_recursive(node: Node) -> MutationInhertitanceHandler:
	var handler := node as MutationInhertitanceHandler

	if handler != null:
		return handler

	for child in node.get_children():
		var found := find_mutation_inheritance_handler_recursive(child)

		if found != null:
			return found

	return null
