extends Node
class_name AttackImpactHandler

signal attack_hit(context: AttackContext)

@export var damage_resolver: AttackDamageResolver

var direct_damage_router: DirectDamageRouter = null


func setup(source_direct_damage_router: DirectDamageRouter) -> void:
	direct_damage_router = source_direct_damage_router


func handle_impact(context: AttackContext, attacker: CardRoot) -> void:
	if context == null:
		return

	attack_hit.emit(context)

	if context.target_slot == null:
		return

	var target_card := context.target_slot.current_card

	if context.force_direct_damage:
		await _request_direct_damage(
			context,
			attacker,
			_get_direct_damage(attacker)
		)
		await _resolve_death_if_needed(attacker)
		return

	if target_card == null:
		await _request_direct_damage(
			context,
			attacker,
			_get_direct_damage(attacker)
		)
		await _resolve_death_if_needed(attacker)
		return

	if target_card.hurt == null:
		return

	var damage: int = _get_attack_damage(attacker, target_card)

	var actual_damage: int = await _play_hurt_without_auto_death(
		target_card,
		damage,
		attacker
	)

	if damage_resolver != null:
		damage_resolver.notify_damage_dealt(
			attacker,
			target_card,
			actual_damage
		)

	var target_was_killed := false

	if (
		is_instance_valid(target_card)
		and target_card.stats != null
	):
		target_was_killed = target_card.stats.is_dead()

	var overflow: int = max(damage - actual_damage, 0)

	if (
		context.carries_over_direct_damage
		and target_was_killed
		and overflow > 0
	):
		await _request_direct_damage(
			context,
			attacker,
			overflow
		)

	await _resolve_death_if_needed(target_card)
	await _resolve_death_if_needed(attacker)


func _play_hurt_without_auto_death(
	target_card: CardRoot,
	damage: int,
	attacker: CardRoot
) -> int:
	if target_card == null:
		return 0

	if target_card.hurt == null:
		return 0

	var original_resolve_death := \
		target_card.hurt.resolve_death_on_hurt_finish

	target_card.hurt.resolve_death_on_hurt_finish = false

	var actual_damage: int = await target_card.hurt.play_hurt(
		damage,
		attacker
	)

	if (
		is_instance_valid(target_card)
		and target_card.hurt != null
	):
		target_card.hurt.resolve_death_on_hurt_finish = \
			original_resolve_death

	return actual_damage


func _resolve_death_if_needed(target_card: CardRoot) -> void:
	if target_card == null:
		return

	if not is_instance_valid(target_card):
		return

	if target_card.stats == null:
		return

	if not target_card.stats.is_dead():
		return

	if target_card.die == null:
		return

	await target_card.die.play_die()


func _get_attack_damage(
	attacker: CardRoot,
	target_card: CardRoot
) -> int:
	if damage_resolver == null:
		return 1

	return damage_resolver.get_attack_damage(
		attacker,
		target_card
	)


func _get_direct_damage(attacker: CardRoot) -> int:
	if damage_resolver == null:
		return 1

	return damage_resolver.get_direct_damage(attacker)


func _request_direct_damage(
	context: AttackContext,
	attacker: CardRoot,
	amount: int
) -> void:
	if direct_damage_router == null:
		return

	if amount <= 0:
		return

	await direct_damage_router.request_direct_damage(
		attacker,
		context.attacker_owner,
		context.target_slot,
		amount
	)
