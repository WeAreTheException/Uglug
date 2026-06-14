extends Node
class_name SacrificeSelectionRoot

signal selection_changed(cards: Array[CardRoot])
signal selection_cleared

var hand_cards: Array[CardRoot] = []
var board_cards: Array[CardRoot] = []


func set_hand_cards(cards: Array[CardRoot]) -> void:
	hand_cards = _clean_cards(cards)
	_emit_changed()


func add_board_card(card: CardRoot) -> void:
	if card == null:
		return

	if board_cards.has(card):
		return

	if hand_cards.has(card):
		return

	board_cards.append(card)
	_emit_changed()


func remove_board_card(card: CardRoot) -> void:
	if not board_cards.has(card):
		return

	board_cards.erase(card)
	_emit_changed()


func clear_board_cards() -> void:
	if board_cards.is_empty():
		return

	board_cards.clear()
	_emit_changed()


func clear_all() -> void:
	hand_cards.clear()
	board_cards.clear()
	selection_cleared.emit()
	_emit_changed()


func get_selected_cards() -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	for card: CardRoot in hand_cards:
		if card != null and not result.has(card):
			result.append(card)

	for card: CardRoot in board_cards:
		if card != null and not result.has(card):
			result.append(card)

	return result


func _clean_cards(cards: Array[CardRoot]) -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	for card: CardRoot in cards:
		if card == null:
			continue

		if result.has(card):
			continue

		result.append(card)

	return result


func _emit_changed() -> void:
	selection_changed.emit(get_selected_cards())
