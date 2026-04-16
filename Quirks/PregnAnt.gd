extends CardQuirk
class_name PregnAnt

@export var spawned_card_data: CardData
@export var spawn_count: int = 2

func on_death(card: Card) -> void:
	if card == null:
		return

	if spawned_card_data == null:
		print("PregnAnt failed: spawned_card_data is null")
		return

	for i in range(spawn_count):
		card.spawn_card_to_hand(spawned_card_data)
