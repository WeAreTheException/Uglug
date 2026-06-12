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
		return

	if target_card == null:
		await _request_direct_damage(
			context,
			attacker,
			_get_direct_damage(attacker)
		)
		return

	if target_card.hurt == null:
		return

	var damage: int = _get_attack_damage(attacker, target_card)
	var health_before: int = _get_card_health(target_card)
	var overflow: int = max(damage - health_before, 0)

	var actual_damage: int = await target_card.hurt.play_hurt(
		damage,
		attacker
	)

	if damage_resolver != null:
		damage_resolver.notify_damage_dealt(
			attacker,
			target_card,
			actual_damage
		)

	if context.carries_over_direct_damage and overflow > 0:
		await _request_direct_damage(context, attacker, overflow)


func _get_attack_damage(attacker: CardRoot, target_card: CardRoot) -> int:
	if damage_resolver == null:
		return 1

	return damage_resolver.get_attack_damage(attacker, target_card)


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


func _get_card_health(card: CardRoot) -> int:
	if card == null:
		return 0

	if card.stats == null:
		return 0

	if card.stats.has_method("get_health"):
		return int(card.stats.get_health())

	var raw_health: Variant = card.stats.get("health")

	if raw_health is int:
		return int(raw_health)

	return 0
