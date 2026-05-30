extends Node
class_name AttackTargetResolver


func get_target_slots(card: CardRoot, slots_root: SlotsRoot) -> Array[Slot]:
	var targets: Array[Slot] = []

	if card == null:
		return targets

	if slots_root == null:
		return targets

	var attacker_slot := card.get_current_slot()

	if attacker_slot == null:
		return targets

	if _has_mutation_named(card, "Y Attack"):
		return slots_root.get_adjacent_enemy_slots(attacker_slot)

	var opposing_slot := slots_root.get_opposing_slot(attacker_slot)

	if opposing_slot != null:
		targets.append(opposing_slot)

	return targets


func _has_mutation_named(card: CardRoot, target_name: String) -> bool:
	if card.mutations == null:
		return false

	for mutation in card.mutations.get_active_mutations():
		if mutation == null:
			continue

		if "mutation_name" in mutation and mutation.mutation_name == target_name:
			return true

	return false
