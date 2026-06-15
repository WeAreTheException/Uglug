extends Resource
class_name Mutation

@export var mutation_name: String = ""
@export_multiline var mutation_description: String = ""
@export var sigil_texture: Texture2D



func get_safe_mutation_id() -> String:
	if mutation_name.strip_edges() == "":
		return ""

	return mutation_name.to_snake_case()
	
	
func get_attack_priority(_runtime: MutationRuntime) -> int:
	return 0


func replaces_base_attack_step(_runtime: MutationRuntime) -> bool:
	return false


func add_attack_steps(
	_runtime: MutationRuntime,
	_steps: Array[AttackStep]
) -> void:
	pass


func modify_attack_steps(
	_runtime: MutationRuntime,
	steps: Array[AttackStep]
) -> Array[AttackStep]:
	return steps


func on_attack_sequence_started_context(
	_runtime: MutationRuntime,
	_context: AttackContext
) -> void:
	pass


func on_attack_sequence_finished_context(
	_runtime: MutationRuntime,
	_context: AttackContext
) -> void:
	pass


func on_placed_context(
	_runtime: MutationRuntime,
	card: CardRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner
) -> void:
	on_placed(card, slot, owner)


func on_struck_context(
	_runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	on_struck(
		context.target_card,
		context.source_card,
		context.final_damage
	)


func modify_attack_target_context(
	runtime: MutationRuntime,
	context: AttackContext
) -> void:
	modify_attack_target(runtime, context)


func modify_outgoing_damage_context(
	_runtime: MutationRuntime,
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

	await on_damaged(
		context.target_card,
		context.source_card,
		context.actual_damage
	)


func on_death_started_context(
	_runtime: MutationRuntime,
	context: DeathContext
) -> void:
	if context == null:
		return

	on_death_started(context.dead_card)


func on_death_context(
	_runtime: MutationRuntime,
	context: DeathContext
) -> void:
	if context == null:
		return

	on_death(context.dead_card)


func on_death_finished_context(
	_runtime: MutationRuntime,
	context: DeathContext
) -> void:
	if context == null:
		return

	on_death_finished(context.dead_card)


func can_intercept_direct_damage_context(
	_runtime: MutationRuntime,
	_context: DirectDamageContext
) -> bool:
	return false


func on_direct_damage_intercepted_context(
	_runtime: MutationRuntime,
	_context: DirectDamageContext
) -> void:
	pass


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	on_left_board(runtime)


func modify_attack_target(
	_runtime: MutationRuntime,
	_context: AttackContext
) -> void:
	pass


func mutation_attack(_card: CardRoot) -> bool:
	return false


func on_placed(
	_card: CardRoot,
	_slot: Slot,
	_owner: SlotRow.SlotOwner
) -> void:
	pass


func on_struck(
	_card: CardRoot,
	_attacker: CardRoot,
	_damage: int
) -> void:
	pass


func on_death_started(_card: CardRoot) -> void:
	pass


func on_death(_card: CardRoot) -> void:
	pass


func on_death_finished(_card: CardRoot) -> void:
	pass


func on_damaged(
	_card: CardRoot,
	_attacker: CardRoot,
	_damage: int
) -> void:
	pass


func on_damage_dealt(
	_card: CardRoot,
	_target: CardRoot,
	_damage: int
) -> void:
	pass


func modify_damage(
	_card: CardRoot,
	_target: CardRoot,
	damage: int
) -> int:
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


func get_attack_target(
	_card: CardRoot,
	target: CardRoot
) -> CardRoot:
	return target


func get_attack_targets(
	_card: CardRoot,
	targets: Array[CardRoot]
) -> Array[CardRoot]:
	return targets
