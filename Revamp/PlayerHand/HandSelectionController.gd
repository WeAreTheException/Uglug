extends Node
class_name HandSelectionController

signal held_card_changed(card: CardRoot)
signal card_held(card: CardRoot)
signal card_released(card: CardRoot)

signal selected_card_changed(card: CardRoot)
signal card_selected(card: CardRoot)
signal card_deselected(card: CardRoot)

@export var hand: PlayerHandRoot
@export var held_z_index: int = 100
@export var selected_z_index: int = 100

var held_card: CardRoot = null
var selected_card: CardRoot = null


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if hand == null:
		return

	hand.card_added.connect(_on_card_added)
	hand.card_removed.connect(_on_card_removed)
	hand.hand_changed.connect(_on_hand_changed)
	hand.hand_mode_changed.connect(_on_hand_mode_changed)

	for card in hand.get_cards():
		_connect_card(card)


func _on_card_pressed(card: CardRoot) -> void:
	if hand == null:
		return

	if hand.current_hand_mode == PhaseManager.HandMode.HAND_ACTIVE:
		toggle_selected_card(card)
	else:
		hold_card(card)


func _on_card_released(card: CardRoot) -> void:
	if hand == null:
		return

	if hand.current_hand_mode == PhaseManager.HandMode.HAND_PASSIVE:
		if held_card == card:
			release_held_card()


func hold_card(card: CardRoot) -> void:
	if card == null:
		return

	if not hand.is_card_in_hand(card):
		return

	release_held_card()

	held_card = card

	if held_card.card_feedback != null:
		held_card.card_feedback.set_selected(true)

	held_card.z_index = held_z_index

	card_held.emit(held_card)
	held_card_changed.emit(held_card)


func release_held_card() -> void:
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


func toggle_selected_card(card: CardRoot) -> void:
	if card == null:
		return

	if not hand.is_card_in_hand(card):
		return

	if hand.hand_prime_controller != null:
		if hand.hand_prime_controller.get_primed_card() == card:
			return

	if selected_card == card:
		clear_selected_card()
		return

	set_selected_card(card)


func set_selected_card(card: CardRoot) -> void:
	if card == null:
		return

	if not hand.is_card_in_hand(card):
		return

	if selected_card != null:
		clear_selected_card()

	selected_card = card

	if selected_card.card_feedback != null:
		selected_card.card_feedback.set_selected(true)

	selected_card.z_index = selected_z_index

	card_selected.emit(selected_card)
	selected_card_changed.emit(selected_card)


func clear_selected_card() -> void:
	if selected_card == null:
		return

	var old_card := selected_card

	if old_card.card_feedback != null:
		old_card.card_feedback.set_selected(false)

	selected_card = null

	card_deselected.emit(old_card)
	selected_card_changed.emit(null)

	if hand != null:
		hand.arrange_cards()


func has_selected_card() -> bool:
	return selected_card != null


func get_selected_card() -> CardRoot:
	return selected_card


func has_held_card() -> bool:
	return held_card != null


func get_held_card() -> CardRoot:
	return held_card


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if held_card == card:
		release_held_card()

	if selected_card == card:
		clear_selected_card()


func _on_hand_changed() -> void:
	if held_card != null:
		held_card.z_index = held_z_index

	if selected_card != null:
		selected_card.z_index = selected_z_index


func _on_hand_mode_changed(mode: PhaseManager.HandMode) -> void:
	if mode == PhaseManager.HandMode.HAND_PASSIVE:
		clear_selected_card()
	else:
		release_held_card()


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	if not card.released.is_connected(_on_card_released):
		card.released.connect(_on_card_released)
