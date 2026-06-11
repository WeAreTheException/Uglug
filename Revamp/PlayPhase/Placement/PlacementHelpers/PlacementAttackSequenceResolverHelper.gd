extends RefCounted
class_name PlacementAttackSequenceResolverHelper


func get_attack_steps(card: CardRoot) -> Array[AttackStep]:
	if card == null:
		return [_make_forward_step()]

	if card.attack == null:
		return [_make_forward_step()]

	if card.attack.attack_sequencer == null:
		return [_make_forward_step()]

	return card.attack.attack_sequencer.build_steps(card)


func get_attack_sequence(card: CardRoot) -> Array[String]:
	var result: Array[String] = []

	for step in get_attack_steps(card):
		if step == null:
			continue

		result.append(step.direction)

	if result.is_empty():
		result.append(AttackStep.FORWARD)

	return result


func _make_forward_step() -> AttackStep:
	var step := AttackStep.new()
	step.setup(AttackStep.FORWARD, MutationSource.BASE, null)

	return step
