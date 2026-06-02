extends Mutation
class_name MutuallyAssuredDestruction


func on_death(card: CardRoot) -> void:
	if card == null:
		return

	if card.slots_root == null:
		return

	var current_slot := card.get_current_slot()

	if current_slot == null:
		return

	var opposing_slot := card.slots_root.get_opposing_slot(current_slot)

	if opposing_slot == null:
		return

	var opposing_card := opposing_slot.current_card

	if opposing_card == null:
		return

	if opposing_card.die == null:
		return

	await opposing_card.die.play_die()
