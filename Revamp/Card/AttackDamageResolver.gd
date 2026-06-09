extends Node
class_name AttackDamageResolver

func get_attack_damage(attacker: CardRoot, target_card: CardRoot) -> int:
	var damage := _get_base_attack(attacker)
	var mutations := _get_mutations(attacker)
	if mutations == null:
		return max(damage, 0)
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			damage = runtime.mutation.modify_damage(attacker, target_card, damage)
	return max(damage, 0)

func notify_damage_dealt(
	attacker: CardRoot,
	target_card: CardRoot,
	damage: int
) -> void:
	if damage <= 0:
		return
	var mutations := _get_mutations(attacker)
	if mutations == null:
		return
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			runtime.mutation.on_damage_dealt(attacker, target_card, damage)

func _get_base_attack(attacker: CardRoot) -> int:
	if attacker == null or attacker.functionality_root == null:
		return 1
	var stats := attacker.functionality_root.stats
	return 1 if stats == null else stats.get_attack()

func _get_mutations(card: CardRoot) -> CardMutations:
	if card == null or card.functionality_root == null:
		return null
	return card.functionality_root.mutations
