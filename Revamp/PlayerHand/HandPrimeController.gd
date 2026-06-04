extends Node
class_name Hand_PrimeController

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)
signal prime_state_changed(can_prime: bool, can_unprime: bool, text: String)

@export var prime_selection: Hand_PrimeSelection
@export var prime_mover: Hand_PrimeMover
@export var prime_on_card_press: bool = true

var interaction_root: Hand_InteractionRoot = null
var primed_card: CardRoot = null

var prime_select_enabled: bool = false
var prime_action_enabled: bool = false


func setup(
	source_interaction_root: Hand_InteractionRoot,
	prime_location: Node2D
) -> void:
	interaction_root = source_interaction_root

	if prime_selection != null:
		prime_selection.setup(self)

	if prime_mover != null:
		prime_mover.setup(self, prime_location)

	_emit_prime_state()


func set_prime_select_enabled(value: bool) -> void:
	prime_select_enabled = value

	if prime_selection != null:
		prime_selection.set_enabled(value)

	_emit_prime_state()


func set_prime_action_enabled(value: bool) -> void:
	prime_action_enabled = value
	_emit_prime_state()


func handle_card_pressed(card: CardRoot) -> void:
	if card == null:
		return

	if card == primed_card:
		unprime_card()
		return

	if not prime_select_enabled:
		return

	if interaction_root == null:
		return

	if not interaction_root.is_card_in_hand(card):
		return

	if prime_selection == null:
		return

	if prime_on_card_press:
		prime_selection.set_selected_card(card)
		prime_selected_card()
	else:
		prime_selection.toggle_card(card)

	_emit_prime_state()


func toggle_prime() -> void:
	if not prime_action_enabled:
		return

	if primed_card != null:
		unprime_card()
	else:
		prime_selected_card()


func prime_selected_card() -> void:
	if not can_prime_selected_card():
		return

	var selected_card := prime_selection.get_selected_card()

	if selected_card == null:
		return

	prime_selection.clear_selection()
	primed_card = selected_card

	if prime_mover != null:
		prime_mover.move_card_to_anchor(primed_card)

	card_primed.emit(primed_card)
	_emit_prime_state()


func unprime_card() -> void:
	if primed_card == null:
		return

	var old_card := primed_card
	primed_card = null

	card_unprimed.emit(old_card)
	_emit_prime_state()


func consume_primed_card(card: CardRoot) -> void:
	if card == null:
		return

	if primed_card != card:
		return

	primed_card = null
	_emit_prime_state()


func clear_selection() -> void:
	if prime_selection != null:
		prime_selection.clear_selection()

	_emit_prime_state()


func forget_card(card: CardRoot) -> void:
	if card == null:
		return

	if prime_selection != null:
		prime_selection.forget_card(card)

	if primed_card == card:
		primed_card = null

	_emit_prime_state()


func can_prime_selected_card() -> bool:
	if not prime_action_enabled:
		return false

	if primed_card != null:
		return false

	if prime_selection == null:
		return false

	var selected_card := prime_selection.get_selected_card()

	if selected_card == null:
		return false

	if interaction_root == null:
		return false

	return interaction_root.is_card_in_hand(selected_card)


func can_unprime() -> bool:
	return prime_action_enabled and primed_card != null


func get_primed_card() -> CardRoot:
	return primed_card


func _emit_prime_state() -> void:
	var text := "Prime"

	if can_unprime():
		text = "Unprime"

	prime_state_changed.emit(
		can_prime_selected_card(),
		can_unprime(),
		text
	)
