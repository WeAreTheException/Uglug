extends Node
class_name HandSelectionController

signal selected_card_changed(card: CardRoot)
signal card_selected(card: CardRoot)
signal card_deselected(card: CardRoot)

@export var hand: PlayerHandRoot

var selected_card: CardRoot = null


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if hand == null:
		return

	hand.card_added.connect(_on_card_added)
	hand.card_removed.connect(_on_card_removed)

	for card in hand.get_cards():
		_connect_card(card)


func select_card(card: CardRoot) -> void:
	if card == null:
		return

	if hand == null:
		return

	if not hand.get_cards().has(card):
		return

	if selected_card == card:
		deselect_current()
		return

	if selected_card != null:
		if selected_card.card_feedback != null:
			selected_card.card_feedback.set_selected(false)

		card_deselected.emit(selected_card)

	selected_card = card

	if selected_card.card_feedback != null:
		selected_card.card_feedback.set_selected(true)

	card_selected.emit(selected_card)
	selected_card_changed.emit(selected_card)


func deselect_current() -> void:
	if selected_card == null:
		return

	var old_card := selected_card

	if old_card.card_feedback != null:
		old_card.card_feedback.set_selected(false)

	selected_card = null

	card_deselected.emit(old_card)
	selected_card_changed.emit(null)


func has_selected_card() -> bool:
	return selected_card != null


func get_selected_card() -> CardRoot:
	return selected_card


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if selected_card == card:
		deselect_current()


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)


func _on_card_pressed(card: CardRoot) -> void:
	select_card(card)
