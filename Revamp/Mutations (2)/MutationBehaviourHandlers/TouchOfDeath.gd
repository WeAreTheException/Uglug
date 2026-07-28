extends Mutation
class_name TouchOfDeath


func on_damage_dealt(
	card: CardRoot,
	target: CardRoot,
	damage: int
) -> void:
	await _kill_target_if_damaged(null, card, target, damage)


func on_damage_dealt_context(
	runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	await _kill_target_if_damaged(
		runtime,
		context.source_card,
		context.target_card,
		context.actual_damage
	)


func _kill_target_if_damaged(
	runtime: MutationRuntime,
	source_card: CardRoot,
	target: CardRoot,
	damage: int
) -> void:
	if target == null:
		return

	if not is_instance_valid(target):
		return

	if damage <= 0:
		return

	if target.stats != null and target.stats.is_dead():
		return

	if target.die == null:
		return

	if runtime != null:
		runtime.trigger_visual()

	var death_context := DeathContext.new()
	death_context.setup(
		target,
		source_card,
		MutationSource.MUTATION,
		self
	)

	await target.die.die_with_context(death_context)
