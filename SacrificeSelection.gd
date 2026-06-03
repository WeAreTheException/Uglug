extends Node
class_name SacrificeSelection

var selected_cards: Array[CardRoot] = []
var card_worths: Dictionary = {}
var current_worth: int = 0


func can_select(card: CardRoot, session: SacrificeSession) -> bool:
	if session == null:
		return false

	if not session.is_active:
		return false

	if card == null:
		return false

	if card == session.primed_card:
		return false

	if selected_cards.has(card):
		return false

	if session.is_requirement_met():
		return false

	return true


func select_card(card: CardRoot, worth: int) -> void:
	if card == null:
		return

	selected_cards.append(card)
	card_worths[card] = worth
	current_worth += worth


func deselect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not selected_cards.has(card):
		return

	selected_cards.erase(card)

	if card_worths.has(card):
		current_worth -= int(card_worths[card])
		card_worths.erase(card)

	current_worth = max(current_worth, 0)


func remove_card(card: CardRoot) -> bool:
	if not selected_cards.has(card):
		return false

	deselect_card(card)
	return true


func has_card(card: CardRoot) -> bool:
	return selected_cards.has(card)


func clear() -> void:
	selected_cards.clear()
	card_worths.clear()
	current_worth = 0
