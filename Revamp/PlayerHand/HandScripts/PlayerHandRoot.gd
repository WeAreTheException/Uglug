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
signal sacrifice_selection_changed(cards: Array[CardRoot])
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
var setup_helper := HandRootSetupHelper.new()
var callbacks := HandRootCallbacksHelper.new()
var placement_release := HandPlacementReleaseHelper.new()
func _ready() -> void:
	callbacks.setup(self)
	setup_helper.setup_root(self, callbacks)
	if spawn_starting_cards_on_ready:
		spawn_starting_cards()
	enter_idle_state()
	arrange_cards()
	emit_prime_state()
func set_hand_input_enabled(value: bool) -> void:
	if interaction_root != null:
		interaction_root.set_input_enabled(value)
func spawn_starting_cards() -> void:
	if card_spawner != null:
		card_spawner.spawn_starting_cards()
func spawn_card(data: CardData) -> CardRoot:
	return null if card_spawner == null else card_spawner.spawn_card(data)
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
	sacrifice_requested.emit(get_primed_card(), get_selected_sacrifice_cards())
func enter_idle_state() -> void:
	if interaction_root != null and interaction_root.can_unprime():
		interaction_root.toggle_prime()
	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.IDLE)
func enter_play_state() -> void:
	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.PLAY)
func enter_sacrifice_state() -> void:
	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.SACRIFICE)
func release_primed_card_for_placement(card: CardRoot) -> void:
	placement_release.release_primed_card_for_placement(card, card_spawner, hand_layout, interaction_root, sacrifice_selection, state_machine)
	emit_prime_state()
func return_primed_card_to_prime_location() -> void:
	if interaction_root != null:
		interaction_root.return_primed_card_to_prime_location()
func get_primed_card() -> CardRoot:
	return null if interaction_root == null else interaction_root.get_primed_card()
func get_selected_sacrifice_cards() -> Array[CardRoot]:
	return [] if sacrifice_selection == null else sacrifice_selection.get_selected_cards()
func clear_sacrifice_selection() -> void:
	if sacrifice_selection != null:
		sacrifice_selection.clear_selection()
func get_index_of_card(card: CardRoot) -> int:
	return -1 if card_spawner == null else card_spawner.get_cards().find(card)
func remove_card_from_hand(card: CardRoot) -> void:
	if card_spawner != null:
		card_spawner.remove_card(card)
func restore_card_to_hand(card: CardRoot, index: int) -> void:
	if card == null or card_spawner == null:
		return
	card.visible = true
	card_spawner.add_card(card)
	card_spawner.move_card_to_index(card, index)
func emit_prime_state() -> void:
	if interaction_root == null:
		prime_state_changed.emit(false, false, "Prime")
		return
	prime_state_changed.emit(interaction_root.can_prime_selected_card(), interaction_root.can_unprime(), interaction_root.get_prime_button_text())
