extends Resource
class_name Mutation

@export var mutation_name: String = ""
@export_multiline var mutation_description: String = ""
@export var sigil_texture: Texture2D


func get_attack_priority(_runtime: MutationRuntime) -> int:
	return 0


func add_attack_steps(runtime: MutationRuntime, steps: Array[AttackStep]) -> void:
	var events: Array[String] = []
	add_attack_events(runtime, events)

	for event in events:
		var step := AttackStep.new()
		step.setup(event, MutationSource.MUTATION, self)
		steps.append(step)


func modify_attack_steps(
	runtime: MutationRuntime,
	steps: Array[AttackStep]
) -> Array[AttackStep]:
	var events: Array[String] = []

	for step in steps:
		if step != null:
			events.append(step.direction)

	events = modify_attack_sequence(runtime, events)

	var result: Array[AttackStep] = []

	for event in events:
		var step := AttackStep.new()
		step.setup(event, MutationSource.BASE, null)
		result.append(step)

	return result


func modify_attack_target_context(
	runtime: MutationRuntime,
	context: AttackContext
) -> void:
	modify_attack_target(runtime, context)


func modify_outgoing_damage_context(
	runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	context.set_final_damage(
		modify_damage(
			context.source_card,
			context.target_card,
			context.final_damage
		)
	)


func modify_incoming_damage_context(
	runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	context.set_final_damage(
		modify_incoming_damage(
			runtime,
			context.target_card,
			context.source_card,
			context.final_damage
		)
	)


func on_damage_dealt_context(
	_runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	on_damage_dealt(
		context.source_card,
		context.target_card,
		context.actual_damage
	)


func on_damaged_context(
	_runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	on_damaged(
		context.target_card,
		context.source_card,
		context.actual_damage
	)


func on_death_context(_runtime: MutationRuntime, context: DeathContext) -> void:
	if context == null:
		return

	on_death(context.dead_card)


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	on_left_board(runtime)


func add_attack_events(_runtime: MutationRuntime, _events: Array[String]) -> void:
	pass


func modify_attack_sequence(
	_runtime: MutationRuntime,
	sequence: Array[String]
) -> Array[String]:
	return sequence


func modify_attack_target(_runtime: MutationRuntime, _context: AttackContext) -> void:
	pass


func mutation_attack(_card: CardRoot) -> bool:
	return false


func on_death(_card: CardRoot) -> void:
	pass


func on_damaged(_card: CardRoot, _attacker: CardRoot, _damage: int) -> void:
	pass


func on_damage_dealt(_card: CardRoot, _target: CardRoot, _damage: int) -> void:
	pass


func modify_damage(_card: CardRoot, _target: CardRoot, damage: int) -> int:
	return damage


func modify_incoming_damage(
	_runtime: MutationRuntime,
	_card: CardRoot,
	_attacker: CardRoot,
	damage: int
) -> int:
	return damage


func refresh_board_effect(_runtime: MutationRuntime) -> void:
	pass


func on_left_board(_runtime: MutationRuntime) -> void:
	pass


func get_attack_target(_card: CardRoot, target: CardRoot) -> CardRoot:
	return target


func get_attack_targets(_card: CardRoot, targets: Array[CardRoot]) -> Array[CardRoot]:
	return targets
