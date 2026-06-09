extends Node
class_name AttackSequencer

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"


func build_sequence(card: CardRoot) -> Array[String]:
	if card == null:
		return [FORWARD]

	if card.mutations == null:
		return [FORWARD]

	return card.mutations.build_attack_events()
