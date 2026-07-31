extends Node
class_name BuffDatabase


@export var buff_pool: Array[EvolutionPoolEntry] = []
@export var forbidden_mutations: Array[Mutation] = []
@export var evolution_seed: int = 67890
@export var print_debug: bool = true
@export var run_smoke_test_on_ready: bool = true


var available_mutations: Array[Mutation] = []
var consumed_mutations: Array[Mutation] = []

var player_one_available_mutations: Array[Mutation] = []
var player_two_available_mutations: Array[Mutation] = []

var split_helper := SeededEvolutionSplitHelper.new()


func _ready() -> void:
	rebuild_available_mutations()

	if run_smoke_test_on_ready:
		debug_smoke_test()


func rebuild_available_mutations() -> void:
	available_mutations.clear()
	player_one_available_mutations.clear()
	player_two_available_mutations.clear()

	var expanded_mutations: Array[Mutation] = (
		_build_expanded_mutation_pool()
	)

	_remove_consumed_copies(
		expanded_mutations
	)

	var split_result: Dictionary = (
		split_helper.split_mutations(
			expanded_mutations,
			_get_seed()
		)
	)

	var player_one_result: Array = (
		split_result.get(
			"player_one_pile",
			[]
		)
	)

	var player_two_result: Array = (
		split_result.get(
			"player_two_pile",
			[]
		)
	)

	for mutation: Mutation in player_one_result:
		if mutation == null:
			continue

		player_one_available_mutations.append(
			mutation
		)

	for mutation: Mutation in player_two_result:
		if mutation == null:
			continue

		player_two_available_mutations.append(
			mutation
		)

	_rebuild_combined_available_mutations()

	if print_debug:
		print(
			"BuffDatabase ready. P1 Evolutions: ",
			player_one_available_mutations.size(),
			" | P2 Evolutions: ",
			player_two_available_mutations.size(),
			" | Total: ",
			available_mutations.size(),
			" | Seed: ",
			_get_seed()
		)


func reset_for_new_match() -> void:
	consumed_mutations.clear()
	rebuild_available_mutations()


func get_available_mutations() -> Array[Mutation]:
	return available_mutations.duplicate()


func get_available_mutations_for_owner(
	owner: SlotRow.SlotOwner
) -> Array[Mutation]:
	return _get_available_pile(owner).duplicate()


func has_available_mutations() -> bool:
	return not available_mutations.is_empty()


func has_available_mutations_for_owner(
	owner: SlotRow.SlotOwner
) -> bool:
	return not _get_available_pile(owner).is_empty()


func draw_random_mutation() -> Mutation:
	if available_mutations.is_empty():
		if print_debug:
			print(
				"BuffDatabase blocked: "
				+ "no available mutations"
			)

		return null

	var mutation := (
		available_mutations.pop_back()
		as Mutation
	)

	_remove_one_copy_from_owner_piles(
		mutation
	)

	_record_consumed_mutation(
		mutation
	)

	if print_debug:
		print(
			"BuffDatabase drew compatibility mutation: ",
			mutation.mutation_name
		)

	return mutation


func draw_mutation_for_owner(
	owner: SlotRow.SlotOwner
) -> Mutation:
	var owner_pile: Array[Mutation] = (
		_get_available_pile(owner)
	)

	if owner_pile.is_empty():
		if print_debug:
			print(
				"BuffDatabase blocked: no Evolution for ",
				_get_owner_name(owner)
			)

		return null

	var mutation := (
		owner_pile.pop_back()
		as Mutation
	)

	available_mutations.erase(
		mutation
	)

	_record_consumed_mutation(
		mutation
	)

	if print_debug:
		print(
			"BuffDatabase drew Evolution for ",
			_get_owner_name(owner),
			": ",
			mutation.mutation_name,
			" | Remaining: ",
			owner_pile.size()
		)

	return mutation


func consume_mutation(
	mutation: Mutation
) -> void:
	if mutation == null:
		return

	var removed_copy := false

	if available_mutations.has(mutation):
		available_mutations.erase(mutation)
		removed_copy = true

	if player_one_available_mutations.has(
		mutation
	):
		player_one_available_mutations.erase(
			mutation
		)
		removed_copy = true
	elif player_two_available_mutations.has(
		mutation
	):
		player_two_available_mutations.erase(
			mutation
		)
		removed_copy = true

	if removed_copy:
		_record_consumed_mutation(
			mutation
		)


func is_consumed(
	mutation: Mutation
) -> bool:
	return consumed_mutations.has(
		mutation
	)


func get_remaining_count() -> int:
	return available_mutations.size()


func get_remaining_count_for_owner(
	owner: SlotRow.SlotOwner
) -> int:
	return _get_available_pile(owner).size()


func debug_smoke_test() -> void:
	print("--- BUFF DATABASE SMOKE TEST ---")
	print("Buff database loads: ", self != null)
	print("Evolution seed: ", _get_seed())

	print(
		"Configured Evolution total: ",
		_get_configured_total_count()
	)

	for entry: EvolutionPoolEntry in buff_pool:
		if entry == null:
			print("INVALID EVOLUTION POOL ENTRY")
			continue

		if entry.mutation == null:
			print(
				"EVOLUTION POOL ENTRY: "
				+ "mutation missing"
			)
			continue

		print(
			"EVOLUTION POOL ENTRY: ",
			entry.mutation.mutation_name,
			" x",
			entry.amount
		)

	print(
		"P1 Evolution count: ",
		player_one_available_mutations.size()
	)

	print(
		"P2 Evolution count: ",
		player_two_available_mutations.size()
	)

	for mutation in player_one_available_mutations:
		print(
			"P1 EVOLUTION: ",
			mutation.mutation_name
		)

	for mutation in player_two_available_mutations:
		print(
			"P2 EVOLUTION: ",
			mutation.mutation_name
		)

	print(
		"Valid forbidden count: ",
		_get_valid_forbidden_count()
	)

	for mutation in forbidden_mutations:
		if _is_valid_mutation_resource(
			mutation
		):
			print(
				"FORBIDDEN MUTATION: ",
				mutation.mutation_name
			)
		else:
			print(
				"INVALID FORBIDDEN MUTATION"
			)

	print(
		"Consumed Evolution copies: ",
		consumed_mutations.size()
	)

	print("--- END BUFF DATABASE SMOKE TEST ---")


func get_mutation_by_id(
	mutation_id: String
) -> Mutation:
	var clean_id := mutation_id.strip_edges()

	if clean_id == "":
		return null

	for entry: EvolutionPoolEntry in buff_pool:
		if entry == null:
			continue

		var mutation: Mutation = entry.mutation

		if mutation == null:
			continue

		if (
			mutation.get_safe_mutation_id()
			== clean_id
		):
			return mutation

	print(
		"BuffDatabase lookup failed: ",
		mutation_id
	)

	return null


func _build_expanded_mutation_pool() -> Array[Mutation]:
	var expanded_mutations: Array[Mutation] = []

	for entry: EvolutionPoolEntry in buff_pool:
		if not _is_valid_pool_entry(entry):
			continue

		for i: int in range(entry.amount):
			expanded_mutations.append(
				entry.mutation
			)

	return expanded_mutations


func _remove_consumed_copies(
	mutations: Array[Mutation]
) -> void:
	for mutation: Mutation in consumed_mutations:
		if mutation == null:
			continue

		mutations.erase(
			mutation
		)


func _record_consumed_mutation(
	mutation: Mutation
) -> void:
	if mutation == null:
		return

	# Duplicate entries are intentional here.
	# Each item represents one consumed copy.
	consumed_mutations.append(
		mutation
	)


func _remove_one_copy_from_owner_piles(
	mutation: Mutation
) -> void:
	if mutation == null:
		return

	if player_one_available_mutations.has(
		mutation
	):
		player_one_available_mutations.erase(
			mutation
		)
		return

	if player_two_available_mutations.has(
		mutation
	):
		player_two_available_mutations.erase(
			mutation
		)


func _is_valid_pool_entry(
	entry: EvolutionPoolEntry
) -> bool:
	if entry == null:
		if print_debug:
			print(
				"BuffDatabase invalid pool entry"
			)

		return false

	if entry.amount <= 0:
		if print_debug:
			print(
				"BuffDatabase excluded pool entry: "
				+ "amount must be above zero"
			)

		return false

	return _is_valid_buff_mutation(
		entry.mutation
	)


func _is_valid_buff_mutation(
	mutation: Mutation
) -> bool:
	if not _is_valid_mutation_resource(
		mutation
	):
		if print_debug:
			print(
				"BuffDatabase invalid buff mutation"
			)

		return false

	if forbidden_mutations.has(mutation):
		if print_debug:
			print(
				"BuffDatabase excluded forbidden mutation: ",
				mutation.mutation_name
			)

		return false

	return true


func _is_valid_mutation_resource(
	mutation: Mutation
) -> bool:
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
		if _is_valid_mutation_resource(
			mutation
		):
			count += 1

	return count


func _get_configured_total_count() -> int:
	var total := 0

	for entry: EvolutionPoolEntry in buff_pool:
		if not _is_valid_pool_entry(entry):
			continue

		total += entry.amount

	return total


func _get_available_pile(
	owner: SlotRow.SlotOwner
) -> Array[Mutation]:
	if owner == SlotRow.SlotOwner.PLAYER:
		return player_one_available_mutations

	return player_two_available_mutations


func _rebuild_combined_available_mutations() -> void:
	available_mutations.clear()

	for mutation in player_one_available_mutations:
		available_mutations.append(
			mutation
		)

	for mutation in player_two_available_mutations:
		available_mutations.append(
			mutation
		)


func _get_seed() -> int:
	return evolution_seed


func _get_owner_name(
	owner: SlotRow.SlotOwner
) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
