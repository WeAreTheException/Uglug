extends Node
class_name SacrificeInputBinder

signal card_pressed(card: CardRoot)
signal card_right_pressed(card: CardRoot)

var bound_cards: Array[CardRoot] = []


func bind_card(card: CardRoot) -> void:
	if card == null:
		return

	if bound_cards.has(card):
		return

	bound_cards.append(card)

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	if not card.right_pressed.is_connected(_on_card_right_pressed):
		card.right_pressed.connect(_on_card_right_pressed)


func unbind_card(card: CardRoot) -> void:
	if card == null:
		return

	bound_cards.erase(card)

	if card.pressed.is_connected(_on_card_pressed):
		card.pressed.disconnect(_on_card_pressed)

	if card.right_pressed.is_connected(_on_card_right_pressed):
		card.right_pressed.disconnect(_on_card_right_pressed)


func clear() -> void:
	for card in bound_cards.duplicate():
		unbind_card(card)

	bound_cards.clear()


func _on_card_pressed(card: CardRoot) -> void:
	card_pressed.emit(card)


func _on_card_right_pressed(card: CardRoot) -> void:
	card_right_pressed.emit(card)
