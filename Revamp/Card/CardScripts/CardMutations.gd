extends Node
class_name CardMutations

signal mutations_changed

@export var max_mutations: int = 3

var owner_card: CardRoot = null
var mutation_runtimes: Array[MutationRuntime] = []


func setup_from_data(data: CardData, new_owner_card: CardRoot) -> void:
	owner_card = new_owner_card
	mutation_runtimes.clear()

	if data == null:
		mutations_changed.emit()
		return

	for mutation in data.base_mutations:
		add_mutation(mutation, owner_card)

	for mutation in data.additional_mutations:
		add_mutation(mutation, owner_card)

	mutations_changed.emit()


func add_mutation(mutation: Mutation, target_card: CardRoot) -> bool:
	if mutation == null:
		return false

	if mutation_runtimes.size() >= max_mutations:
		return false

	var runtime := MutationRuntime.new()
	runtime.setup(mutation, target_card)

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
		if runtime != null and runtime.can_use():
			result.append(runtime)

	return result


func get_all_mutations() -> Array[Mutation]:
	var result: Array[Mutation] = []

	for runtime in mutation_runtimes:
		if runtime != null and runtime.mutation != null:
			result.append(runtime.mutation)

	return result


func get_active_mutations() -> Array[Mutation]:
	var result: Array[Mutation] = []

	for runtime in get_active_runtimes():
		if runtime.mutation != null:
			result.append(runtime.mutation)

	return result


func tick_turn_durations() -> void:
	for runtime in mutation_runtimes:
		if runtime != null:
			runtime.tick_turn_duration()

	mutations_changed.emit()


func get_attack_priority() -> int:
	var total_priority := 0

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		total_priority += runtime.mutation.get_attack_priority(runtime)

	return total_priority


func build_attack_steps() -> Array[AttackStep]:
	var steps: Array[AttackStep] = []

	if not _should_replace_base_attack():
		steps.append(_make_base_attack_step())

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.add_attack_steps(runtime, steps)

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		steps = runtime.mutation.modify_attack_steps(runtime, steps)

	if steps.is_empty():
		steps.append(_make_base_attack_step())

	return steps


func build_attack_events() -> Array[String]:
	var events: Array[String] = []

	for step in build_attack_steps():
		if step == null:
			continue

		events.append(step.direction)

	if events.is_empty():
		events.append(AttackStep.FORWARD)

	return events


func modify_attack_target(context: AttackContext) -> void:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.modify_attack_target(runtime, context)


func modify_outgoing_damage(target_card: CardRoot, damage: int) -> int:
	var result := damage

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		result = runtime.mutation.modify_damage(owner_card, target_card, result)

	return max(result, 0)


func notify_damage_dealt(target_card: CardRoot, damage: int) -> void:
	if damage <= 0:
		return

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_damage_dealt(owner_card, target_card, damage)


func modify_incoming_damage(attacker: CardRoot, damage: int) -> int:
	var result := damage

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		result = runtime.mutation.modify_incoming_damage(
			runtime,
			owner_card,
			attacker,
			result
		)

	return max(result, 0)


func notify_damaged(attacker: CardRoot, damage: int) -> void:
	if damage <= 0:
		return

	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_damaged(owner_card, attacker, damage)

func can_intercept_direct_damage(context: DirectDamageContext) -> bool:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if runtime.mutation.can_intercept_direct_damage_context(runtime, context):
			return true

	return false


func notify_direct_damage_intercepted(context: DirectDamageContext) -> void:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_direct_damage_intercepted_context(runtime, context)
func notify_death() -> void:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_death(owner_card)


func refresh_board_effects() -> void:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.refresh_board_effect(runtime)


func notify_left_board() -> void:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_left_board(runtime)


func _should_replace_base_attack() -> bool:
	for runtime in get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if runtime.mutation.replaces_base_attack_step(runtime):
			return true

	return false


func _make_base_attack_step() -> AttackStep:
	var step := AttackStep.new()
	step.setup(AttackStep.FORWARD, MutationSource.BASE, null)

	return step
