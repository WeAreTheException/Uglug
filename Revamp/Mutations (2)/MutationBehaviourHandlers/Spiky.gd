extends Mutation
class_name Spiky

@export var counter_damage: int = 1


func on_damaged(
	card: CardRoot,
	attacker: CardRoot,
	damage: int
) -> void:
	await _counter_attack(null, card, attacker, damage)


func on_damaged_context(
	runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	await _counter_attack(
		runtime,
		context.target_card,
		context.source_card,
		context.actual_damage
	)


func _counter_attack(
	runtime: MutationRuntime,
	card: CardRoot,
	attacker: CardRoot,
	damage: int
) -> void:
	if card == null:
		return

	if attacker == null:
		return

	if not is_instance_valid(attacker):
		return

	if damage <= 0:
		return

	if counter_damage <= 0:
		return

	if attacker.hurt == null:
		return

	if runtime != null:
		runtime.trigger_visual()

	var original_resolve_death := attacker.hurt.resolve_death_on_hurt_finish
	attacker.hurt.resolve_death_on_hurt_finish = false

	await attacker.hurt.play_hurt(
		counter_damage,
		card,
		false
	)

	if is_instance_valid(attacker) and attacker.hurt != null:
		attacker.hurt.resolve_death_on_hurt_finish = original_resolve_death
