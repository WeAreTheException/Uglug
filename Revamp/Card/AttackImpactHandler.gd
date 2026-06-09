extends Node
class_name AttackImpactHandler

signal attack_hit(context: AttackContext)

@export var damage_resolver: AttackDamageResolver
var attacker: CardRoot = null

func setup(source_attacker: CardRoot) -> void:
	attacker = source_attacker

func handle_impact(context: AttackContext) -> void:
	if context == null:
		return
	attack_hit.emit(context)
	if context.target_slot == null:
		return
	var target_card := context.target_slot.current_card
	if target_card == null:
		return
	var damage := _get_damage(target_card)
	var damage_context := DamageContext.new()
	damage_context.setup_combat(context, damage)
	var actual_damage: int = await target_card.receive_damage(damage_context)
	_notify_damage_dealt(target_card, actual_damage)

func _get_damage(target_card: CardRoot) -> int:
	if damage_resolver == null:
		return 1
	return damage_resolver.get_attack_damage(attacker, target_card)

func _notify_damage_dealt(target_card: CardRoot, damage: int) -> void:
	if damage_resolver != null:
		damage_resolver.notify_damage_dealt(attacker, target_card, damage)
