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

	if target_card == null:
		_request_direct_damage(context, attacker, 1)
		return

	if target_card.hurt == null:
		return

	var damage := 1

	if damage_resolver != null:
		damage = damage_resolver.get_attack_damage(attacker, target_card)

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


func _request_direct_damage(
	context: AttackContext,
	attacker: CardRoot,
	amount: int
) -> void:
	if direct_damage_router == null:
		return

	direct_damage_router.request_direct_damage(
		attacker,
		context.attacker_owner,
		context.target_slot,
		amount
	)
