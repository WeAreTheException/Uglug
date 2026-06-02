extends Node
class_name HandSelectionController

signal held_card_changed(card: CardRoot)
signal card_held(card: CardRoot)
signal card_released(card: CardRoot)

@export var hand: PlayerHandRoot
@export var held_z_index: int = 100

var held_card: CardRoot = null


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if hand == null:
		return

	hand.card_added.connect(_on_card_added)
	hand.card_removed.connect(_on_card_removed)
	hand.hand_changed.connect(_on_hand_changed)

	for card in hand.get_cards():
		_connect_card(card)


func hold_card(card: CardRoot) -> void:
	if card == null:
		return

	if hand == null:
		return

	if not hand.is_card_in_hand(card):
		return

	if held_card == card:
		return

	release_current()

	held_card = card

	if held_card.card_feedback != null:
		held_card.card_feedback.set_selected(true)

	held_card.z_index = held_z_index

	card_held.emit(held_card)
	held_card_changed.emit(held_card)


func release_current() -> void:
	if held_card == null:
		return

	var old_card := held_card

	if old_card.card_feedback != null:
		old_card.card_feedback.set_selected(false)

	held_card = null

	card_released.emit(old_card)
	held_card_changed.emit(null)

	if hand != null:
		hand.arrange_cards()


func has_held_card() -> bool:
	return held_card != null


func get_held_card() -> CardRoot:
	return held_card


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if held_card == card:
		release_current()


func _on_hand_changed() -> void:
	if held_card != null:
		held_card.z_index = held_z_index


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	if not card.released.is_connected(_on_card_released):
		card.released.connect(_on_card_released)


func _on_card_pressed(card: CardRoot) -> void:
	hold_card(card)


func _on_card_released(card: CardRoot) -> void:
	if held_card == card:
		release_current()
