extends Node
class_name SacrificeHandler

signal sacrifice_selection_changed(current_worth: int, required_worth: int)
signal sacrifice_requirement_met(current_worth: int, required_worth: int)
signal sacrifice_requirement_unmet(current_worth: int, required_worth: int)
signal sacrifice_card_selected(card: CardRoot)
signal sacrifice_card_deselected(card: CardRoot)

@export var player_hand_root: PlayerHandRoot

var primed_card: CardRoot = null
var selected_cards: Array[CardRoot] = []

var required_worth: int = 0
var current_worth: int = 0
var is_active := false


func _ready() -> void:
	if player_hand_root == null:
		return

	if not player_hand_root.card_primed.is_connected(_on_card_primed):
		player_hand_root.card_primed.connect(_on_card_primed)

	if not player_hand_root.card_unprimed.is_connected(_on_card_unprimed):
		player_hand_root.card_unprimed.connect(_on_card_unprimed)

	if not player_hand_root.card_added.is_connected(_on_card_added):
		player_hand_root.card_added.connect(_on_card_added)

	if not player_hand_root.card_removed.is_connected(_on_card_removed):
		player_hand_root.card_removed.connect(_on_card_removed)

	for card in player_hand_root.get_cards():
		_connect_card(card)


func _on_card_primed(card: CardRoot) -> void:
	_clear_all()

	primed_card = card
	required_worth = card.get_sacrifice_cost()
	current_worth = 0
	is_active = true

	for hand_card in player_hand_root.get_cards():
		_connect_card(hand_card)

	_update_state()


func _on_card_unprimed(_card: CardRoot) -> void:
	_clear_all()


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if selected_cards.has(card):
		selected_cards.erase(card)
		_update_current_worth()
		_update_state()


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	if not card.right_pressed.is_connected(_on_card_right_pressed):
		card.right_pressed.connect(_on_card_right_pressed)


func _on_card_pressed(card: CardRoot) -> void:
	if not is_active:
		return

	if card == null:
		return

	if card == primed_card:
		return

	if selected_cards.has(card):
		return

	if _is_requirement_met():
		return

	selected_cards.append(card)
	current_worth += card.get_sacrifice_worth()

	card.set_sacrifice_selected(true)

	sacrifice_card_selected.emit(card)
	_update_state()


func _on_card_right_pressed(card: CardRoot) -> void:
	if not is_active:
		return

	if card == null:
		return

	if not selected_cards.has(card):
		return

	selected_cards.erase(card)
	_update_current_worth()

	card.set_sacrifice_selected(false)

	sacrifice_card_deselected.emit(card)
	_update_state()


func _update_current_worth() -> void:
	current_worth = 0

	for card in selected_cards:
		if card == null:
			continue

		current_worth += card.get_sacrifice_worth()


func _is_requirement_met() -> bool:
	return current_worth >= required_worth


func _update_state() -> void:
	sacrifice_selection_changed.emit(current_worth, required_worth)

	if _is_requirement_met():
		sacrifice_requirement_met.emit(current_worth, required_worth)
	else:
		sacrifice_requirement_unmet.emit(current_worth, required_worth)


func _clear_all() -> void:
	if player_hand_root != null:
		for card in player_hand_root.get_cards():
			if card == null:
				continue

			card.set_sacrifice_selected(false)
			card.stop_sacrifice_anticipation()

	selected_cards.clear()
	primed_card = null
	required_worth = 0
	current_worth = 0
	is_active = false

	_update_state()
