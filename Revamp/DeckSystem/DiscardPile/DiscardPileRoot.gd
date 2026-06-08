extends Node
class_name DiscardPileRoot

signal card_sent_to_death_pile(card: CardRoot)
signal card_sent_to_sacrifice_pile(card: CardRoot)

@export var death_pile: DeathPile
@export var sacrifice_pile: SacrificePile


func add_dead_card(card: CardRoot) -> void:
	if death_pile != null:
		death_pile.add_card(card)
	card_sent_to_death_pile.emit(card)


func add_sacrificed_card(card: CardRoot) -> void:
	if sacrifice_pile != null:
		sacrifice_pile.add_card(card)
	card_sent_to_sacrifice_pile.emit(card)


func get_discard_count() -> int:
	var total := 0
	if death_pile != null:
		total += death_pile.count()
	if sacrifice_pile != null:
		total += sacrifice_pile.count()
	return total
