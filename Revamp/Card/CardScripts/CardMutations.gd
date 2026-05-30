extends Node
class_name CardMutations

signal mutations_changed

@export var max_mutations: int = 3

var mutation_runtimes: Array[MutationRuntime] = []


func setup_from_data(data: CardData, owner_card: CardRoot) -> void:
	mutation_runtimes.clear()

	if data == null:
		mutations_changed.emit()
		return

	for mutation in data.base_mutations:
		add_mutation(mutation, owner_card)

	for mutation in data.additional_mutations:
		add_mutation(mutation, owner_card)

	mutations_changed.emit()


func add_mutation(mutation: Mutation, owner_card: CardRoot) -> bool:
	if mutation == null:
		return false

	if mutation_runtimes.size() >= max_mutations:
		return false

	var runtime := MutationRuntime.new()
	runtime.setup(mutation, owner_card)

	mutation_runtimes.append(runtime)

	mutations_changed.emit()

	return true


func remove_runtime(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	mutation_runtimes.erase(runtime)

	mutations_changed.emit()


func get_all_runtimes() -> Array[MutationRuntime]:
	return mutation_runtimes.duplicate()


func get_active_runtimes() -> Array[MutationRuntime]:
	var result: Array[MutationRuntime] = []

	for runtime in mutation_runtimes:
		if runtime == null:
			continue

		if runtime.can_use():
			result.append(runtime)

	return result


func get_all_mutations() -> Array[Mutation]:
	var result: Array[Mutation] = []

	for runtime in mutation_runtimes:
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		result.append(runtime.mutation)

	return result


func get_active_mutations() -> Array[Mutation]:
	var result: Array[Mutation] = []

	for runtime in get_active_runtimes():
		result.append(runtime.mutation)

	return result


func tick_turn_durations() -> void:
	for runtime in mutation_runtimes:
		if runtime == null:
			continue

		runtime.tick_turn_duration()

	mutations_changed.emit()
