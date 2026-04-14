extends Node
class_name OpponentController

@export var opponent_hand: NewPlayerHand
@export var slots: Array[Node2D]   # each = one pair root

func place_cards() -> void:
	if opponent_hand == null:
		print("OpponentController: opponent_hand null")
		return

	if slots.is_empty():
		print("OpponentController: slots empty")
		return

	var cards: Array = opponent_hand.player_hand.duplicate()
	if cards.is_empty():
		print("OpponentController: no cards to place")
		return

	var empty_slots: Array[NewSlots] = get_all_empty_opponent_slots()

	print("OpponentController: cards in hand = ", cards.size())
	print("OpponentController: empty slots = ", empty_slots.size())

	if empty_slots.is_empty():
		print("OpponentController: no empty opponent slots")
		return

	var count: int = min(cards.size(), empty_slots.size())

	for i in range(count):
		var card = cards[i]
		var slot: NewSlots = empty_slots[i]

		opponent_hand.remove_card_from_hand(card)
		card.place_into_slot(slot)

		if slot.get_parent() != null:
			print("Card has been placed in ", slot.get_parent().name)
		else:
			print("Card has been placed in ", slot.name)

func get_all_empty_opponent_slots() -> Array[NewSlots]:
	var empty_slots: Array[NewSlots] = []

	for pair_root in slots:
		if pair_root == null:
			continue

		for child in pair_root.get_children():
			if child is NewSlots:
				var slot := child as NewSlots
				if slot.slot_owner == NewSlots.SlotOwner.OPPONENT and slot.is_empty():
					empty_slots.append(slot)

	return empty_slots
