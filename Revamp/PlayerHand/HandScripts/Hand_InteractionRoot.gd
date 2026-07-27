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
@export var drag_controller: Hand_DragController
@export var prime_controller: Hand_PrimeController

var card_spawner: Hand_CardSpawner = null
var hand_layout: Hand_Layout = null
var hand_card_layer: Node2D = null
var drag_layer: Node2D = null

var input_enabled: bool = true
var drag_active: bool = false

var layer_mover := HandCardLayerMoverHelper.new()
var setup_helper := HandInteractionSetupHelper.new()
var callbacks := HandInteractionCallbacksHelper.new()


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

	callbacks.setup(self)
	setup_helper.setup_children(
		self,
		callbacks,
		prime_location
	)
	setup_helper.connect_spawner(
		self,
		callbacks
	)

	_refresh_card_hover_input()


func set_input_enabled(value: bool) -> void:
	input_enabled = value

	if input_router != null:
		input_router.set_input_enabled(value)

	_refresh_card_hover_input()


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
	if prime_controller != null:
		prime_controller.consume_primed_card(card)

	if hand_layout != null:
		hand_layout.clear_primed_card()


func return_primed_card_to_prime_location() -> void:
	if prime_controller != null:
		prime_controller.return_primed_card_to_prime_location()


func clear_prime_selection() -> void:
	if prime_controller != null:
		prime_controller.clear_selection()


func can_prime_selected_card() -> bool:
	return (
		prime_controller != null
		and prime_controller.can_prime_selected_card()
	)


func can_unprime() -> bool:
	return (
		prime_controller != null
		and prime_controller.can_unprime()
	)


func get_prime_button_text() -> String:
	return "Unprime" if can_unprime() else "Prime"


func get_primed_card() -> CardRoot:
	if prime_controller == null:
		return null

	return prime_controller.get_primed_card()


func is_card_in_hand(card: CardRoot) -> bool:
	return (
		card_spawner != null
		and card_spawner.is_card_in_hand(card)
	)


func get_cards() -> Array[CardRoot]:
	if card_spawner == null:
		return []

	return card_spawner.get_cards()


func get_card_index(card: CardRoot) -> int:
	return get_cards().find(card)


func move_card_to_index(
	card: CardRoot,
	new_index: int
) -> void:
	if card_spawner != null:
		card_spawner.move_card_to_index(
			card,
			new_index
		)

	refresh_hover_focus()


func arrange_cards() -> void:
	if hand_layout != null:
		hand_layout.arrange_cards(
			get_cards()
		)


func get_insert_index_from_global_x(
	global_x: float
) -> int:
	if hand_layout == null:
		return 0

	return hand_layout.get_insert_index_from_global_x(
		global_x,
		get_cards()
	)


func get_top_hovered_card() -> CardRoot:
	if hover_focus == null:
		return null

	return hover_focus.get_top_card(
		get_cards()
	)


func refresh_hover_focus() -> void:
	if hover_focus != null:
		hover_focus.refresh(
			get_cards()
		)


func apply_input_state_to_card(
	card: CardRoot
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	card.set_card_input_enabled(
		input_enabled
		and not drag_active
	)


func set_card_hover_input_enabled(
	value: bool
) -> void:
	for card: CardRoot in get_cards():
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if card.input == null:
			continue

		card.set_card_input_enabled(value)


func begin_drag(card: CardRoot) -> void:
	if card == null:
		return

	drag_active = true
	_refresh_card_hover_input()

	if hand_layout != null:
		hand_layout.clear_ignored_card()

	layer_mover.move_to_layer(
		card,
		drag_layer
	)

	arrange_cards()
	refresh_hover_focus()


func finish_drag(card: CardRoot) -> void:
	drag_active = false

	if card == null:
		_refresh_card_hover_input()
		return

	layer_mover.move_to_layer(
		card,
		hand_card_layer
	)

	if hand_layout != null:
		hand_layout.clear_ignored_card()

	arrange_cards()

	_refresh_card_hover_input()
	refresh_hover_focus()


func _refresh_card_hover_input() -> void:
	var should_enable: bool = (
		input_enabled
		and not drag_active
	)

	set_card_hover_input_enabled(
		should_enable
	)
