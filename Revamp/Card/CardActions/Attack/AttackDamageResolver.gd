extends Node
class_name AttackDamageResolver


func get_attack_damage(attacker: CardRoot, target_card: CardRoot) -> int:
	var damage := 1

	if attacker != null and attacker.stats != null:
		damage = attacker.stats.get_attack()

	if attacker == null:
		return max(damage, 0)

	if attacker.mutations == null:
		return max(damage, 0)

	return attacker.mutations.modify_outgoing_damage(target_card, damage)


func notify_damage_dealt(
	attacker: CardRoot,
	target_card: CardRoot,
	damage: int
) -> void:
	if damage <= 0:
		return

	if attacker == null:
		return

	if attacker.mutations == null:
		return

	attacker.mutations.notify_damage_dealt(target_card, damage)
