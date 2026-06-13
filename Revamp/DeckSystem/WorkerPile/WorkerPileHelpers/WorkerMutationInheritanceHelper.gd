extends RefCounted
class_name WorkerMutationInheritanceHelper


func apply_inherited_mutations(
	source_card: CardRoot,
	spawned_worker: CardRoot
) -> void:
	if source_card == null:
		return

	if spawned_worker == null:
		return

	if not is_instance_valid(source_card):
		return

	if not is_instance_valid(spawned_worker):
		return

	if source_card.mutations == null:
		return

	if spawned_worker.mutations == null:
		return

	var inherited_mutations: Array[Mutation] = source_card.mutations.get_inheritable_mutations()

	for mutation: Mutation in inherited_mutations:
		if mutation == null:
			continue

		spawned_worker.mutations.add_buff_mutation(mutation)
