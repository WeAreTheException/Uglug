extends Node
class_name Hand_PrimeSelection

signal selected_card_changed(card: CardRoot)
signal card_selected(card: CardRoot)
signal card_deselected(card: CardRoot)

@export var selected_z_index: int = 100

var prime_controller: Hand_PrimeController = null
var selected_card: CardRoot = null
var is_enabled: bool = false


func setup(source_prime_controller: Hand_PrimeController) -> void:
	prime_controller = source_prime_controller


func set_enabled(value: bool) -> void:
	is_enabled = value

	if not is_enabled:
		clear_selection()


func toggle_card(card: CardRoot) -> void:
	if not is_enabled:
		return

	if card == null:
		return

	if selected_card == card:
		clear_selection()
	else:
		set_selected_card(card)


func set_selected_card(card: CardRoot) -> void:
	if not is_enabled:
		return

	if card == null:
		return

	if selected_card != null:
		clear_selection()

	selected_card = card
	selected_card.z_index = selected_z_index
	selected_card.set_prime_select_feedback(true)

	card_selected.emit(selected_card)
	selected_card_changed.emit(selected_card)


func clear_selection() -> void:
	if selected_card == null:
		return

	var old_card := selected_card
	old_card.set_prime_select_feedback(false)

	selected_card = null

	card_deselected.emit(old_card)
	selected_card_changed.emit(null)


func forget_card(card: CardRoot) -> void:
	if selected_card == card:
		clear_selection()


func get_selected_card() -> CardRoot:
	return selected_card
