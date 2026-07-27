extends Mutation
class_name TouchOfDeath


func on_damage_dealt(
	card: CardRoot,
	target: CardRoot,
	damage: int
) -> void:
	await _kill_target_if_damaged(card, target, damage)


func on_damage_dealt_context(
	_runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	await _kill_target_if_damaged(
		context.source_card,
		context.target_card,
		context.actual_damage
	)


func _kill_target_if_damaged(
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

	var death_context := DeathContext.new()
	death_context.setup(
		target,
		source_card,
		MutationSource.MUTATION,
		self
	)

	await target.die.die_with_context(death_context)
