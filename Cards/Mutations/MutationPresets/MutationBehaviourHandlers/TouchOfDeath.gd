extends Mutation
class_name TouchOfDeath


func on_damage_dealt(
	_card: CardRoot,
	target: CardRoot,
	damage: int
) -> void:
	if damage <= 0:
		return

	if target == null:
		return

	if target.stats == null:
		return

	if target.stats.is_dead():
		return

	if target.die == null:
		return

	await target.die.play_die()
