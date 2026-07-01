extends Mutation
class_name Shield


func modify_incoming_damage(
	runtime: MutationRuntime,
	_card: CardRoot,
	_attacker: CardRoot,
	damage: int
) -> int:
	if runtime == null:
		return damage

	if damage <= 0:
		return damage

	runtime.deactivate()

	return 0
