extends Node
class_name AttackDamageResolver


func get_attack_damage(attacker: CardRoot, target_card: CardRoot) -> int:
	var damage: int = 1

	if attacker != null and attacker.stats != null:
		damage = attacker.stats.get_attack()

	if attacker == null:
		return max(damage, 0)

	if attacker.mutations == null:
		return max(damage, 0)

	damage = attacker.mutations.modify_outgoing_damage(
		target_card,
		damage
	)

	return max(damage, 0)


func get_direct_damage(attacker: CardRoot) -> int:
	if attacker == null:
		return 1

	if attacker.stats == null:
		return 1

	return max(attacker.stats.get_attack(), 0)


func notify_damage_dealt(
	attacker: CardRoot,
	target_card: CardRoot,
	damage: int
) -> void:
	if damage <= 0:
		return

	if attacker == null:
		return

	if not is_instance_valid(attacker):
		return

	if attacker.mutations == null:
		return

	await attacker.mutations.notify_damage_dealt(
		target_card,
		damage
	)
