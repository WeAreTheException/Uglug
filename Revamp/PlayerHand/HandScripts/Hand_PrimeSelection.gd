extends Node
class_name Hand_PrimeSelection

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
	if selected_card == card:
		clear_selection()
	else:
		set_selected_card(card)


func set_selected_card(card: CardRoot) -> void:
	if not is_enabled:
		return

	if card == null:
		return

	clear_selection()

	selected_card = card
	selected_card.set_prime_select_feedback(true)


func clear_selection() -> void:
	if selected_card != null:
		selected_card.set_prime_select_feedback(false)

	selected_card = null


func forget_card(card: CardRoot) -> void:
	if selected_card == card:
		selected_card = null


func get_selected_card() -> CardRoot:
	return selected_card
