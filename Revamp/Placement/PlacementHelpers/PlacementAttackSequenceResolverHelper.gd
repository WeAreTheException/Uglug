extends RefCounted
class_name PlacementAttackSequenceResolverHelper


func get_attack_sequence(card: CardRoot) -> Array[String]:
	if card == null:
		return [AttackSequencer.FORWARD]

	if card.attack == null:
		return [AttackSequencer.FORWARD]

	if card.attack.attack_sequencer == null:
		return [AttackSequencer.FORWARD]

	return card.attack.attack_sequencer.build_sequence(card)
