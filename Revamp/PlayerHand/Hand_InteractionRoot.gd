extends Node
class_name Hand_InteractionRoot

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)
signal prime_state_changed(can_prime: bool, can_unprime: bool, text: String)

signal card_left_pressed(card: CardRoot)
signal card_left_released(card: CardRoot)
signal card_right_pressed(card: CardRoot)

@export var input_router: Hand_InputRouter
@export var hover_focus: Hand_HoverFocus
@export var card_layer_mover: Hand_CardLayerMover
@export var drag_controller: Hand_DragController
@export var prime_controller: Hand_PrimeController

var card_spawner: Hand_CardSpawner = null
var hand_layout: Hand_Layout = null
var hand_card_layer: Node2D = null
var drag_layer: Node2D = null


func setup(
	new_card_spawner: Hand_CardSpawner,
	new_hand_layout: Hand_Layout,
	new_hand_card_layer: Node2D,
	new_drag_layer: Node2D,
	prime_location: Node2D
) -> void:
	card_spawner = new_card_spawner
	hand_layout = new_hand_layout
	hand_card_layer = new_hand_card_layer
	drag_layer = new_drag_layer

	_setup_children(prime_location)
	_connect_card_spawner()


func set_input_enabled(value: bool) -> void:
	if input_router != null:
		input_router.set_input_enabled(value)


func set_drag_enabled(value: bool) -> void:
	if drag_controller != null:
		drag_controller.set_drag_enabled(value)


func set_prime_select_enabled(value: bool) -> void:
	if prime_controller != null:
		prime_controller.set_prime_select_enabled(value)


func set_prime_action_enabled(value: bool) -> void:
	if prime_controller != null:
		prime_controller.set_prime_action_enabled(value)


func toggle_prime() -> void:
	if prime_controller != null:
		prime_controller.toggle_prime()


func consume_primed_card_silent(card: CardRoot) -> void:
	if prime_controller == null:
		return

	if prime_controller.get_primed_card() != card:
		return

	prime_controller.consume_primed_card(card)

	if hand_layout != null:
		hand_layout.clear_primed_card()


func clear_prime_selection() -> void:
	if prime_controller != null:
		prime_controller.clear_selection()


func can_prime_selected_card() -> bool:
	return prime_controller != null and prime_controller.can_prime_selected_card()


func can_unprime() -> bool:
	return prime_controller != null and prime_controller.can_unprime()


func get_prime_button_text() -> String:
	if can_unprime():
		return "Unprime"

	return "Prime"


func get_primed_card() -> CardRoot:
	if prime_controller == null:
		return null

	return prime_controller.get_primed_card()


func is_card_in_hand(card: CardRoot) -> bool:
	return card_spawner != null and card_spawner.is_card_in_hand(card)


func get_cards() -> Array[CardRoot]:
	if card_spawner == null:
		return []

	return card_spawner.get_cards()


func get_card_index(card: CardRoot) -> int:
	return get_cards().find(card)


func move_card_to_index(card: CardRoot, new_index: int) -> void:
	if card_spawner != null:
		card_spawner.move_card_to_index(card, new_index)

	refresh_hover_focus()


func arrange_cards() -> void:
	if hand_layout != null:
		hand_layout.arrange_cards(get_cards())


func get_insert_index_from_global_x(global_x: float) -> int:
	if hand_layout == null:
		return 0

	return hand_layout.get_insert_index_from_global_x(global_x, get_cards())


func get_top_hovered_card() -> CardRoot:
	if hover_focus == null:
		return null

	return hover_focus.get_top_card(get_cards())


func refresh_hover_focus() -> void:
	if hover_focus != null:
		hover_focus.refresh(get_cards())


func begin_drag(card: CardRoot) -> void:
	if hand_layout != null:
		hand_layout.clear_ignored_card()

	if card_layer_mover != null:
		card_layer_mover.move_to_layer(card, drag_layer)

	arrange_cards()
	refresh_hover_focus()


func finish_drag(card: CardRoot) -> void:
	if card_layer_mover != null:
		card_layer_mover.move_to_layer(card, hand_card_layer)

	if hand_layout != null:
		hand_layout.clear_ignored_card()

	arrange_cards()
	refresh_hover_focus()


func _setup_children(prime_location: Node2D) -> void:
	if input_router != null:
		input_router.setup(self)
		input_router.card_left_pressed.connect(_on_card_left_pressed)
		input_router.card_left_released.connect(_on_card_left_released)
		input_router.card_right_pressed.connect(_on_card_right_pressed)

	if hover_focus != null:
		hover_focus.setup(self)

	if card_layer_mover != null:
		card_layer_mover.setup(self)

	if drag_controller != null:
		drag_controller.setup(self)

	if prime_controller != null:
		prime_controller.setup(self, prime_location)
		prime_controller.card_primed.connect(_on_card_primed)
		prime_controller.card_unprimed.connect(_on_card_unprimed)
		prime_controller.prime_state_changed.connect(_on_prime_state_changed)


func _connect_card_spawner() -> void:
	if card_spawner == null:
		return

	card_spawner.card_added.connect(_on_card_added)
	card_spawner.card_removed.connect(_on_card_removed)

	for card in card_spawner.get_cards():
		_bind_card(card)


func _bind_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.hovered.is_connected(_on_card_hovered):
		card.hovered.connect(_on_card_hovered)

	if not card.unhovered.is_connected(_on_card_unhovered):
		card.unhovered.connect(_on_card_unhovered)


func _on_card_added(card: CardRoot) -> void:
	_bind_card(card)
	refresh_hover_focus()


func _on_card_removed(card: CardRoot) -> void:
	var was_primed := false

	if prime_controller != null:
		was_primed = prime_controller.get_primed_card() == card

	if hover_focus != null:
		hover_focus.forget_card(card)

	if drag_controller != null:
		drag_controller.forget_card(card)

	if prime_controller != null:
		prime_controller.forget_card(card)

	if was_primed and hand_layout != null:
		hand_layout.clear_primed_card()

	refresh_hover_focus()


func _on_card_hovered(card: CardRoot) -> void:
	if hover_focus != null:
		hover_focus.add_hovered_card(card)


func _on_card_unhovered(card: CardRoot) -> void:
	if hover_focus != null:
		hover_focus.remove_hovered_card(card)


func _on_card_left_pressed(card: CardRoot) -> void:
	if drag_controller != null:
		drag_controller.handle_card_pressed(card)

	if prime_controller != null:
		prime_controller.handle_card_pressed(card)

	card_left_pressed.emit(card)


func _on_card_left_released(card: CardRoot) -> void:
	if drag_controller != null:
		drag_controller.handle_card_released(card)

	card_left_released.emit(card)


func _on_card_right_pressed(card: CardRoot) -> void:
	card_right_pressed.emit(card)


func _on_card_primed(card: CardRoot) -> void:
	if hand_layout != null:
		hand_layout.set_primed_card(card)

	arrange_cards()
	card_primed.emit(card)


func _on_card_unprimed(card: CardRoot) -> void:
	if hand_layout != null:
		hand_layout.clear_primed_card()

	arrange_cards()
	card_unprimed.emit(card)


func _on_prime_state_changed(can_prime: bool, can_unprime: bool, text: String) -> void:
	prime_state_changed.emit(can_prime, can_unprime, text)

func return_primed_card_to_prime_location() -> void:
	if prime_controller != null:
		prime_controller.return_primed_card_to_prime_location()
