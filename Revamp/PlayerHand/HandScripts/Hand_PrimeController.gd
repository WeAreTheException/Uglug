extends Node
class_name Hand_PrimeController

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)
signal prime_state_changed(can_prime: bool, can_unprime: bool, text: String)

@export var prime_selection: Hand_PrimeSelection
@export var prime_mover: Hand_PrimeMover
@export var prime_on_card_press: bool = true
@export var zero_cost_skips_prime_location: bool = true

var interaction_root: Hand_InteractionRoot = null
var prime_select_enabled: bool = false
var prime_action_enabled: bool = false
var state := HandPrimeStateHelper.new()


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

	if card == state.primed_card:
		unprime_card()
		return

	if not _can_select_card(card):
		return

	if state.has_primed_card():
		unprime_card()

	if prime_on_card_press:
		prime_selection.set_selected_card(card)
		prime_selected_card()
	else:
		prime_selection.toggle_card(card)

	_emit_prime_state()


func toggle_prime() -> void:
	if not prime_action_enabled:
		return

	if state.has_primed_card():
		unprime_card()
	else:
		prime_selected_card()


func prime_selected_card() -> void:
	if not can_prime_selected_card():
		return

	var selected_card := prime_selection.get_selected_card()

	prime_selection.clear_selection()
	state.set_primed_card(selected_card)

	selected_card.set_prime_select_feedback(true)

	card_primed.emit(selected_card)
	_emit_prime_state()


func unprime_card() -> void:
	if not state.has_primed_card():
		return

	var old_card := state.clear_primed_card()

	if old_card != null:
		old_card.set_prime_select_feedback(false)

	card_unprimed.emit(old_card)
	_emit_prime_state()


func consume_primed_card(card: CardRoot) -> void:
	if state.consume_card(card):
		if card != null:
			card.set_prime_select_feedback(false)

		_emit_prime_state()


func return_primed_card_to_prime_location() -> void:
	pass


func clear_selection() -> void:
	if prime_selection != null:
		prime_selection.clear_selection()

	_emit_prime_state()


func forget_card(card: CardRoot) -> void:
	if prime_selection != null:
		prime_selection.forget_card(card)

	if state.primed_card == card:
		state.clear_primed_card()

	if card != null:
		card.set_prime_select_feedback(false)

	_emit_prime_state()


func can_prime_selected_card() -> bool:
	if not prime_action_enabled:
		return false

	if state.has_primed_card():
		return false

	if prime_selection == null:
		return false

	return _can_select_card(prime_selection.get_selected_card())


func can_unprime() -> bool:
	return prime_action_enabled and state.has_primed_card()


func get_primed_card() -> CardRoot:
	return state.primed_card


func _can_select_card(card: CardRoot) -> bool:
	return (
		prime_select_enabled
		and card != null
		and interaction_root != null
		and interaction_root.is_card_in_hand(card)
	)


func _emit_prime_state() -> void:
	var text := "Unprime" if can_unprime() else "Prime"
	prime_state_changed.emit(can_prime_selected_card(), can_unprime(), text)
