extends Node
class_name SacrificeSelectionRoot

signal selection_changed(cards: Array[CardRoot])
signal selection_cleared

var hand_cards: Array[CardRoot] = []
var board_cards: Array[CardRoot] = []
var pending_cards: Array[CardRoot] = []

var primed_card: CardRoot = null
var requirement := SacrificeRequirement.new()


func set_primed_card(card: CardRoot) -> void:
	primed_card = card

	if primed_card != null:
		remove_hand_card(primed_card)
		remove_board_card(primed_card)
		remove_pending_card(primed_card)

	_trim_to_requirement()
	_emit_changed()


func set_hand_cards(cards: Array[CardRoot]) -> void:
	hand_cards.clear()

	for card in _clean_cards(cards):
		if _can_add_card(card):
			hand_cards.append(card)
		else:
			card.set_sacrifice_selected(false)

	_emit_changed()


func set_pending_cards(cards: Array[CardRoot]) -> void:
	pending_cards = _clean_cards(cards)
	_emit_changed()


func clear_pending_cards() -> void:
	if pending_cards.is_empty():
		return

	pending_cards.clear()
	_emit_changed()


func add_board_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if board_cards.has(card):
		return false

	if hand_cards.has(card):
		return false

	if pending_cards.has(card):
		return false

	if not _can_add_card(card):
		return false

	board_cards.append(card)
	_emit_changed()
	return true


func remove_hand_card(card: CardRoot) -> void:
	if not hand_cards.has(card):
		return

	hand_cards.erase(card)
	_emit_changed()


func remove_board_card(card: CardRoot) -> void:
	if not board_cards.has(card):
		return

	board_cards.erase(card)
	_emit_changed()


func remove_pending_card(card: CardRoot) -> void:
	if not pending_cards.has(card):
		return

	pending_cards.erase(card)
	_emit_changed()


func clear_board_cards() -> void:
	if board_cards.is_empty():
		return

	for card: CardRoot in board_cards:
		if card == null:
			continue

		card.set_sacrifice_selected(false)
		card.stop_sacrifice_anticipation()
		card.reset_sacrifice_feedback()

	board_cards.clear()
	_emit_changed()


func clear_all() -> void:
	for card: CardRoot in get_selected_cards():
		if card == null:
			continue

		card.set_sacrifice_selected(false)
		card.stop_sacrifice_anticipation()
		card.reset_sacrifice_feedback()

	hand_cards.clear()
	board_cards.clear()
	pending_cards.clear()

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

	for card: CardRoot in pending_cards:
		if card != null and not result.has(card):
			result.append(card)

	return result


func _can_add_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if card == primed_card:
		return false

	if primed_card == null:
		return true

	var required_worth := requirement.get_required_worth(primed_card)

	if required_worth <= 0:
		return false

	var current_cards := get_selected_cards()

	if current_cards.has(card):
		return true

	var current_worth := requirement.get_current_worth(current_cards)
	var added_worth := card.get_sacrifice_worth()

	return current_worth < required_worth and current_worth + added_worth <= required_worth


func _trim_to_requirement() -> void:
	if primed_card == null:
		return

	var required_worth := requirement.get_required_worth(primed_card)

	if required_worth <= 0:
		_clear_with_feedback()
		return

	while requirement.get_current_worth(get_selected_cards()) > required_worth:
		var removed := _remove_last_selected_card()

		if removed == null:
			return

		removed.set_sacrifice_selected(false)


func _remove_last_selected_card() -> CardRoot:
	if not board_cards.is_empty():
		return board_cards.pop_back()

	if not hand_cards.is_empty():
		return hand_cards.pop_back()

	if not pending_cards.is_empty():
		return pending_cards.pop_back()

	return null


func _clear_with_feedback() -> void:
	for card in get_selected_cards():
		if card != null:
			card.set_sacrifice_selected(false)
			card.stop_sacrifice_anticipation()
			card.reset_sacrifice_feedback()

	hand_cards.clear()
	board_cards.clear()
	pending_cards.clear()


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
