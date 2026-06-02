extends Mutation
class_name Spiky

@export var counter_damage: int = 1


func on_damaged(
	card: CardRoot,
	attacker: CardRoot,
	_damage: int
) -> void:
	if card == null:
		return

	if attacker == null:
		return

	if attacker.hurt == null:
		return

	await attacker.hurt.play_hurt(
		counter_damage,
		card,
		false
	)
