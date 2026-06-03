extends Node
class_name SacrificeCommitter

signal card_committed(card: CardRoot)
signal cards_committed(cards: Array[CardRoot])


func commit_cards(cards: Array[CardRoot]) -> void:
	var committed_cards: Array[CardRoot] = []

	for card in cards:
		if card == null:
			continue

		_commit_card(card)
		committed_cards.append(card)

	cards_committed.emit(committed_cards)


func _commit_card(card: CardRoot) -> void:
	card.set_sacrifice_selected(false)
	card.stop_sacrifice_anticipation()
	card.clear_hand_feedback()

	card_committed.emit(card)
	card.queue_free()
