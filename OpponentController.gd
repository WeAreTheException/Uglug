extends Node
class_name OpponentController

@export var opponent_hand: NewPlayerHand
@export var enemy_slots: Array[NewSlots]

func place_cards() -> void:
	if opponent_hand == null:
		print("OpponentController: opponent_hand null")
		return

	if enemy_slots.is_empty():
		print("OpponentController: enemy_slots empty")
		return

	var cards: Array = opponent_hand.player_hand.duplicate()
	if cards.is_empty():
		print("OpponentController: no cards to place")
		return

	var empty_slots: Array[NewSlots] = []
	for slot in enemy_slots:
		if slot != null and slot.is_empty():
			empty_slots.append(slot)

	print("OpponentController: cards in hand = ", cards.size())
	print("OpponentController: empty enemy slots = ", empty_slots.size())

	if empty_slots.is_empty():
		print("OpponentController: no empty slots")
		return

	var count: int = min(cards.size(), empty_slots.size())

	for i in range(count):
		var card = cards[i]
		var slot: NewSlots = empty_slots[i]

		print("Placing card into slot: ", card.card_name)

		opponent_hand.remove_card_from_hand(card)
		card.place_into_slot(slot)
