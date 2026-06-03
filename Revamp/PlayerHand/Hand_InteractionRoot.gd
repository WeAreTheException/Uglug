extends Node
class_name Hand_InteractionRoot

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)
signal prime_state_changed(can_prime: bool, can_unprime: bool, text: String)

signal card_left_pressed(card: CardRoot)
signal card_left_released(card: CardRoot)
signal card_right_pressed(card: CardRoot)

@export var drag_controller: Hand_DragController
@export var prime_controller: Hand_PrimeController

var card_spawner: Hand_CardSpawner = null
var hand_layout: Hand_Layout = null
var hand_card_layer: Node2D = null
var drag_layer: Node2D = null

var hovered_cards: Array[CardRoot] = []
var focused_card: CardRoot = null
var pressed_card: CardRoot = null


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

	_setup_drag_controller()
	_setup_prime_controller(prime_location)
	_connect_card_spawner()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)


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


func clear_prime_selection() -> void:
	if prime_controller != null:
		prime_controller.clear_selection()


func can_prime_selected_card() -> bool:
	if prime_controller == null:
		return false

	return prime_controller.can_prime_selected_card()


func can_unprime() -> bool:
	if prime_controller == null:
		return false

	return prime_controller.can_unprime()


func get_prime_button_text() -> String:
	if can_unprime():
		return "Unprime"

	return "Prime"


func get_primed_card() -> CardRoot:
	if prime_controller == null:
		return null

	return prime_controller.get_primed_card()


func is_card_in_hand(card: CardRoot) -> bool:
	if card_spawner == null:
		return false

	return card_spawner.is_card_in_hand(card)


func get_cards() -> Array[CardRoot]:
	if card_spawner == null:
		return []

	return card_spawner.get_cards()


func move_card_to_index(card: CardRoot, new_index: int) -> void:
	if card_spawner != null:
		card_spawner.move_card_to_index(card, new_index)


func get_insert_index_from_global_x(global_x: float) -> int:
	if hand_layout == null:
		return 0

	return hand_layout.get_insert_index_from_global_x(global_x, get_cards())


func arrange_cards() -> void:
	if hand_layout != null:
		hand_layout.arrange_cards(get_cards())


func begin_drag(card: CardRoot) -> void:
	if hand_layout != null:
		hand_layout.set_ignored_card(card)

	arrange_cards()
	_move_card_to_layer(card, drag_layer)


func finish_drag(card: CardRoot) -> void:
	_move_card_to_layer(card, hand_card_layer)

	if hand_layout != null:
		hand_layout.clear_ignored_card()

	arrange_cards()


func _setup_drag_controller() -> void:
	if drag_controller != null:
		drag_controller.setup(self)


func _setup_prime_controller(prime_location: Node2D) -> void:
	if prime_controller == null:
		return

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


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_mouse(event)

	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var card := _get_top_hovered_card()
		if card != null:
			card_right_pressed.emit(card)


func _handle_left_mouse(event: InputEventMouseButton) -> void:
	if event.pressed:
		pressed_card = _get_top_hovered_card()

		if pressed_card == null:
			return

		if drag_controller != null:
			drag_controller.handle_card_pressed(pressed_card)

		if prime_controller != null:
			prime_controller.handle_card_pressed(pressed_card)

		card_left_pressed.emit(pressed_card)
	else:
		if pressed_card == null:
			return

		if drag_controller != null:
			drag_controller.handle_card_released(pressed_card)

		card_left_released.emit(pressed_card)
		pressed_card = null


func _get_top_hovered_card() -> CardRoot:
	var top_card: CardRoot = null
	var top_z := -999999
	var top_index := -999999

	for card in hovered_cards:
		if card == null:
			continue

		if not is_card_in_hand(card):
			continue

		var index := get_cards().find(card)

		if card.z_index > top_z or (card.z_index == top_z and index > top_index):
			top_card = card
			top_z = card.z_index
			top_index = index

	return top_card


func _refresh_focus() -> void:
	var new_focus := _get_top_hovered_card()

	if focused_card == new_focus:
		return

	if focused_card != null:
		focused_card.set_hover_focused(false)

	focused_card = new_focus

	if focused_card != null:
		focused_card.set_hover_focused(true)


func _on_card_hovered(card: CardRoot) -> void:
	if not hovered_cards.has(card):
		hovered_cards.append(card)

	_refresh_focus()


func _on_card_unhovered(card: CardRoot) -> void:
	hovered_cards.erase(card)

	if focused_card == card:
		focused_card.set_hover_focused(false)
		focused_card = null

	_refresh_focus()


func _on_card_added(card: CardRoot) -> void:
	_bind_card(card)


func _on_card_removed(card: CardRoot) -> void:
	hovered_cards.erase(card)

	if focused_card == card:
		focused_card = null

	if drag_controller != null:
		drag_controller.forget_card(card)

	if prime_controller != null:
		prime_controller.forget_card(card)


func _move_card_to_layer(card: CardRoot, target_layer: Node2D) -> void:
	if card == null or target_layer == null:
		return

	if card.get_parent() == target_layer:
		return

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	target_layer.add_child(card)
	card.global_transform = saved_global_transform


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
