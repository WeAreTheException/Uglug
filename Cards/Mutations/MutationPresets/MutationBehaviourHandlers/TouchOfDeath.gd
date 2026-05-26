extends Mutation
class_name TouchOfDeath

func modify_damage(attacker: Card, defender: Card, base_damage: int) -> int:
	if defender == null:
		return base_damage

	return defender.current_health
