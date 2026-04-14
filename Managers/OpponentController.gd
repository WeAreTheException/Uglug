extends Node
class_name OpponentController

@export var opponent_hand: NewPlayerHand
@export var enemy_slot_roots: Array[Node2D]

func place_cards() -> void:
	if opponent_hand == null:
		print("OpponentController: opponent_hand null")
		return

	if enemy_slot_roots.is_empty():
		print("OpponentController: enemy_slot_roots empty")
		return

	var cards: Array = opponent_hand.player_hand.duplicate()
	if cards.is_empty():
		print("OpponentController: no cards to place")
		return

	var empty_slots: Array[NewSlots] = []

	for slot_root in enemy_slot_roots:
		var slot := get_new_slot_from_root(slot_root)
		if slot != null and slot.is_empty():
			empty_slots.append(slot)

	print("OpponentController: cards in hand = ", cards.size())
	print("OpponentController: empty slots = ", empty_slots.size())

	if empty_slots.is_empty():
		print("OpponentController: no empty slots")
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

func get_new_slot_from_root(slot_root: Node2D) -> NewSlots:
	if slot_root == null:
		return null

	for child in slot_root.get_children():
		if child is NewSlots:
			return child

	return null
