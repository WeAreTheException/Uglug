extends Node
class_name BuffDatabase

@export var buff_pool: Array[Mutation] = []
@export var forbidden_mutations: Array[Mutation] = []
@export var print_debug: bool = true
@export var run_smoke_test_on_ready: bool = true

var available_mutations: Array[Mutation] = []
var consumed_mutations: Array[Mutation] = []


func _ready() -> void:
	rebuild_available_mutations()

	if run_smoke_test_on_ready:
		debug_smoke_test()


func rebuild_available_mutations() -> void:
	available_mutations.clear()

	for mutation in buff_pool:
		if not _is_valid_buff_mutation(mutation):
			continue

		if available_mutations.has(mutation):
			continue

		available_mutations.append(mutation)

	available_mutations.shuffle()

	if print_debug:
		print("BuffDatabase ready. Valid buffs: ", available_mutations.size())


func get_available_mutations() -> Array[Mutation]:
	return available_mutations.duplicate()


func has_available_mutations() -> bool:
	return not available_mutations.is_empty()


func draw_random_mutation() -> Mutation:
	if available_mutations.is_empty():
		if print_debug:
			print("BuffDatabase blocked: no available mutations")

		return null

	var mutation := available_mutations.pop_back() as Mutation
	consume_mutation(mutation)

	if print_debug:
		print("BuffDatabase drew mutation: ", mutation.mutation_name)

	return mutation


func consume_mutation(mutation: Mutation) -> void:
	if mutation == null:
		return

	if not consumed_mutations.has(mutation):
		consumed_mutations.append(mutation)

	available_mutations.erase(mutation)


func is_consumed(mutation: Mutation) -> bool:
	return consumed_mutations.has(mutation)


func get_remaining_count() -> int:
	return available_mutations.size()


func debug_smoke_test() -> void:
	print("--- BUFF DATABASE SMOKE TEST ---")
	print("Buff database loads: ", self != null)
	print("Valid buff count: ", available_mutations.size())

	for mutation in available_mutations:
		print("VALID BUFF: ", mutation.mutation_name)

	print("Valid forbidden count: ", _get_valid_forbidden_count())

	for mutation in forbidden_mutations:
		if _is_valid_mutation_resource(mutation):
			print("FORBIDDEN MUTATION: ", mutation.mutation_name)
		else:
			print("INVALID FORBIDDEN MUTATION")

	print("Consumed mutation count: ", consumed_mutations.size())
	print("--- END BUFF DATABASE SMOKE TEST ---")


func _is_valid_buff_mutation(mutation: Mutation) -> bool:
	if not _is_valid_mutation_resource(mutation):
		if print_debug:
			print("BuffDatabase invalid buff mutation")

		return false

	if forbidden_mutations.has(mutation):
		if print_debug:
			print("BuffDatabase excluded forbidden mutation: ", mutation.mutation_name)

		return false

	if consumed_mutations.has(mutation):
		if print_debug:
			print("BuffDatabase excluded consumed mutation: ", mutation.mutation_name)

		return false

	return true


func _is_valid_mutation_resource(mutation: Mutation) -> bool:
	if mutation == null:
		return false

	if mutation.mutation_name.strip_edges() == "":
		return false

	if mutation.sigil_texture == null:
		return false

	return true


func _get_valid_forbidden_count() -> int:
	var count := 0

	for mutation in forbidden_mutations:
		if _is_valid_mutation_resource(mutation):
			count += 1

	return count

func get_mutation_by_id(mutation_id: String) -> Mutation:
	var clean_id := mutation_id.strip_edges()

	if clean_id == "":
		return null

	for mutation: Mutation in buff_pool:
		if mutation == null:
			continue

		if mutation.get_safe_mutation_id() == clean_id:
			return mutation

	print("BuffDatabase lookup failed: ", mutation_id)
	return null
