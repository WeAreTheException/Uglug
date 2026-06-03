extends Node2D
class_name PlayerHandRoot

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal hand_changed
signal hand_state_changed(state_name: String)

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)
signal prime_state_changed(can_prime: bool, can_unprime: bool, text: String)
signal sacrifice_requested(primed_card: CardRoot, hand_cards: Array[CardRoot])

@export var card_scene: PackedScene
@export var starting_cards: Array[CardData]
@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3

@export var hand_card_layer: Node2D
@export var drag_layer: Node2D
@export var prime_location: Node2D

@export var prime_button_root: Node
@export var sort_buttons_root: Node
@export var sacrifice_button_root: Node

@export var card_spawner: Hand_CardSpawner
@export var hand_layout: Hand_Layout
@export var sort_controller: Hand_SortController
@export var state_machine: Hand_StateMachine
@export var interaction_root: Hand_InteractionRoot
@export var sacrifice_selection: Hand_SacrificeSelection

@export var spawn_starting_cards_on_ready: bool = true


func _ready() -> void:
	_setup_spawner()
	_setup_interaction()
	_setup_sacrifice_selection()
	_setup_sort()
	_setup_state_machine()
	_connect_external_buttons()

	if spawn_starting_cards_on_ready:
		spawn_starting_cards()

	enter_idle_state()
	arrange_cards()
	_emit_prime_state()


func _setup_spawner() -> void:
	if card_spawner == null:
		return

	card_spawner.configure(card_scene, starting_cards, hand_card_layer, max_hand_size, minimum_hand_size)

	card_spawner.card_added.connect(_on_card_added)
	card_spawner.card_removed.connect(_on_card_removed)
	card_spawner.hand_changed.connect(_on_hand_changed)


func _setup_interaction() -> void:
	if interaction_root == null:
		return

	interaction_root.setup(card_spawner, hand_layout, hand_card_layer, drag_layer, prime_location)

	interaction_root.card_primed.connect(_on_card_primed)
	interaction_root.card_unprimed.connect(_on_card_unprimed)
	interaction_root.prime_state_changed.connect(_on_prime_state_changed)
	interaction_root.card_left_pressed.connect(_on_hand_card_left_pressed)
	interaction_root.card_right_pressed.connect(_on_hand_card_right_pressed)


func _setup_sacrifice_selection() -> void:
	if sacrifice_selection != null:
		sacrifice_selection.setup(card_spawner)


func _setup_sort() -> void:
	if sort_controller != null:
		sort_controller.setup(card_spawner)


func _setup_state_machine() -> void:
	if state_machine == null:
		return

	state_machine.setup(hand_layout, interaction_root, sort_controller, sacrifice_selection)
	state_machine.state_changed.connect(_on_hand_state_changed)


func _connect_external_buttons() -> void:
	_connect_signal(prime_button_root, "prime_pressed", request_prime_toggle)
	_connect_signal(sort_buttons_root, "sort_by_cost_pressed", request_sort_by_cost)
	_connect_signal(sort_buttons_root, "sort_by_mutation_pressed", request_sort_by_mutation_count)
	_connect_signal(sacrifice_button_root, "sacrifice_pressed", request_sacrifice)


func _connect_signal(source: Object, signal_name: StringName, target: Callable) -> void:
	if source != null and source.has_signal(signal_name) and not source.is_connected(signal_name, target):
		source.connect(signal_name, target)


func spawn_starting_cards() -> void:
	if card_spawner != null:
		card_spawner.spawn_starting_cards()


func spawn_card(data: CardData) -> CardRoot:
	if card_spawner == null:
		return null

	return card_spawner.spawn_card(data)


func arrange_cards() -> void:
	if hand_layout != null and card_spawner != null:
		hand_layout.arrange_cards(card_spawner.get_cards())


func request_prime_toggle() -> void:
	if interaction_root != null:
		interaction_root.toggle_prime()


func request_sort_by_cost() -> void:
	if sort_controller != null:
		sort_controller.sort_by_cost()


func request_sort_by_mutation_count() -> void:
	if sort_controller != null:
		sort_controller.sort_by_mutation_count()


func request_sacrifice() -> void:
	if sacrifice_selection != null:
		sacrifice_requested.emit(get_primed_card(), sacrifice_selection.get_selected_cards())


func enter_idle_state() -> void:
	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.IDLE)


func enter_play_state() -> void:
	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.PLAY)


func enter_sacrifice_state() -> void:
	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.SACRIFICE)


func get_primed_card() -> CardRoot:
	if interaction_root == null:
		return null

	return interaction_root.get_primed_card()


func _on_card_added(card: CardRoot) -> void:
	card_added.emit(card)


func _on_card_removed(card: CardRoot) -> void:
	card_removed.emit(card)


func _on_hand_changed() -> void:
	hand_changed.emit()
	arrange_cards()

	if interaction_root != null:
		interaction_root.refresh_hover_focus()

	_emit_prime_state()


func _on_card_primed(card: CardRoot) -> void:
	card_primed.emit(card)
	enter_sacrifice_state()
	_emit_prime_state()


func _on_card_unprimed(card: CardRoot) -> void:
	card_unprimed.emit(card)
	enter_play_state()
	_emit_prime_state()


func _on_hand_card_left_pressed(card: CardRoot) -> void:
	if sacrifice_selection != null:
		sacrifice_selection.handle_card_pressed(card)


func _on_hand_card_right_pressed(card: CardRoot) -> void:
	if sacrifice_selection != null:
		sacrifice_selection.handle_card_right_pressed(card)


func _on_prime_state_changed(can_prime: bool, can_unprime: bool, text: String) -> void:
	prime_state_changed.emit(can_prime, can_unprime, text)


func _on_hand_state_changed(state_name: String) -> void:
	hand_state_changed.emit(state_name)
	arrange_cards()
	_emit_prime_state()


func _emit_prime_state() -> void:
	if interaction_root == null:
		prime_state_changed.emit(false, false, "Prime")
		return

	prime_state_changed.emit(
		interaction_root.can_prime_selected_card(),
		interaction_root.can_unprime(),
		interaction_root.get_prime_button_text()
	)
