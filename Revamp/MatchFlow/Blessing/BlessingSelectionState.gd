extends Node
class_name BlessingSelectionState

signal selection_changed(slot_owner: SlotRow.SlotOwner, card: CardRoot)
signal selections_cleared

var selected_cards: Dictionary = {}


func clear_selections() -> void:
	selected_cards.clear()
	selections_cleared.emit()


func select_card(slot_owner: SlotRow.SlotOwner, card: CardRoot) -> void:
	if card == null:
		return

	selected_cards[slot_owner] = card
	selection_changed.emit(slot_owner, card)


func has_selection(slot_owner: SlotRow.SlotOwner) -> bool:
	return selected_cards.has(slot_owner)


func get_selected_card(slot_owner: SlotRow.SlotOwner) -> CardRoot:
	if not selected_cards.has(slot_owner):
		return null

	var card := selected_cards[slot_owner] as CardRoot

	if card == null:
		return null

	if not is_instance_valid(card):
		selected_cards.erase(slot_owner)
		return null

	return card


func has_all_selections() -> bool:
	return (
		has_selection(SlotRow.SlotOwner.PLAYER)
		and has_selection(SlotRow.SlotOwner.OPPONENT)
	)


func is_selected_card(card: CardRoot) -> bool:
	if card == null:
		return false

	for selected_card in selected_cards.values():
		if selected_card == card:
			return true

	return false
