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

	for runtime in attacker.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		damage = runtime.mutation.modify_damage(
			attacker,
			target_card,
			damage
		)

	return max(damage, 0)


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

	for runtime in attacker.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_damage_dealt(
			attacker,
			target_card,
			damage
		)
