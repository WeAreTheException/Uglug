extends CardQuirk
class_name TrainingArc

@export var turns_needed: int = 1
@export var health_gain: int = 2

func on_turn_end(card: Card) -> void:
	if card == null:
		return

	if card.training_arc_used:
		return

	card.quirk_turn_counter += 1

	if card.quirk_turn_counter < turns_needed:
		return

	card.heal(health_gain)
	card.training_arc_used = true

	print(card.card_name, " TrainingArc triggered")
