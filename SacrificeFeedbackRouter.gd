extends Node
class_name SacrificeFeedbackRouter


func set_card_selected(card: CardRoot, value: bool) -> void:
	if card == null:
		return

	card.set_sacrifice_selected(value)

	if not value:
		card.stop_sacrifice_anticipation()


func clear_cards(cards: Array[CardRoot]) -> void:
	for card in cards:
		set_card_selected(card, false)
