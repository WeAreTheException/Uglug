extends CardQuirk
class_name PregnAnt

@export var draw_count: int = 2

func on_death(card: Card) -> void:
	if card == null:
		return

	card.draw_worker_cards(draw_count)
