extends Mutation
class_name Lifesteal

@export var heal_amount: int = 1


func modify_damage(
	card: CardRoot,
	_target: CardRoot,
	damage: int
) -> int:
	if card == null:
		return damage

	if card.stats == null:
		return damage

	if damage <= 0:
		return damage

	card.stats.heal(heal_amount)

	return damage
