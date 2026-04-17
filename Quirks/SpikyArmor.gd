extends CardQuirk
class_name SpikyArmor

@export var return_damage: int = 1

func on_damaged(card: Card, attacker: Card, amount: int) -> void:
	if card == null:
		return

	if attacker == null:
		return

	if amount <= 0:
		return

	if not is_instance_valid(attacker):
		return

	attacker.take_damage(return_damage)
