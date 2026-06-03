extends Node2D
class_name PlayerHandRoot

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal hand_changed
signal hand_mode_changed(mode: PhaseManager.HandMode)

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)

@export var card_scene: PackedScene
@export var starting_cards: Array[CardData]

@export var hand_cards_layer: Node2D
@export var drag_layer: Node2D
@export var hand_layout: HandLayout

@export var hand_mode_controller: HandModeController
@export var hand_selection_controller: HandSelectionController
@export var hand_prime_controller: HandPrimeController
@export var hand_buttons_root: PlayerHandButtonsRoot

@export var prime_anchor: Node2D

@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3

var current_cards: Array[CardRoot] = []
var current_hand_mode: PhaseManager.HandMode = PhaseManager.HandMode.HAND_PASSIVE


func _ready() -> void:
	_connect_hand_buttons()
	_connect_selection()
	_connect_prime_controller()

	spawn_starting_cards()
	arrange_cards()
	set_hand_mode(current_hand_mode)


func _connect_hand_buttons() -> void:
	if hand_buttons_root == null:
		return

	if not hand_buttons_root.prime_pressed.is_connected(_on_prime_pressed):
		hand_buttons_root.prime_pressed.connect(_on_prime_pressed)


func _connect_selection() -> void:
	if hand_selection_controller == null:
		return

	if not hand_selection_controller.selected_card_changed.is_connected(_on_selected_card_changed):
		hand_selection_controller.selected_card_changed.connect(_on_selected_card_changed)


func _connect_prime_controller() -> void:
	if hand_prime_controller == null:
		return

	if not hand_prime_controller.card_primed.is_connected(_on_card_primed):
		hand_prime_controller.card_primed.connect(_on_card_primed)

	if not hand_prime_controller.card_unprimed.is_connected(_on_card_unprimed):
		hand_prime_controller.card_unprimed.connect(_on_card_unprimed)


func set_hand_mode(mode: PhaseManager.HandMode) -> void:
	current_hand_mode = mode

	if hand_mode_controller != null:
		hand_mode_controller.set_hand_mode(mode)

	hand_mode_changed.emit(mode)
	arrange_cards()
	_update_prime_button_state()


func spawn_starting_cards() -> void:
	for data in starting_cards:
		if current_cards.size() >= max_hand_size:
			return

		spawn_card(data)


func spawn_card(data: CardData) -> CardRoot:
	if data == null:
		return null

	if card_scene == null:
		return null

	if hand_cards_layer == null:
		return null

	if is_full():
		return null

	var card := card_scene.instantiate() as CardRoot

	if card == null:
		return null

	hand_cards_layer.add_child(card)
	card.position = Vector2.ZERO
	card.setup(data)

	add_card(card)

	return card


func add_card(card: CardRoot) -> void:
	if card == null:
		return

	if current_cards.has(card):
		return

	if is_full():
		return

	current_cards.append(card)

	card_added.emit(card)
	hand_changed.emit()

	arrange_cards()
	_update_prime_button_state()


func remove_card(card: CardRoot) -> void:
	if card == null:
		return

	if not current_cards.has(card):
		return

	current_cards.erase(card)

	card_removed.emit(card)
	hand_changed.emit()

	arrange_cards()
	_update_prime_button_state()


func move_card_to_index(card: CardRoot, new_index: int) -> void:
	if card == null:
		return

	if not current_cards.has(card):
		return

	current_cards.erase(card)

	var clamped_index := clampi(new_index, 0, current_cards.size())
	current_cards.insert(clamped_index, card)

	hand_changed.emit()
	arrange_cards()


func sort_cards(compare_function: Callable) -> void:
	current_cards.sort_custom(compare_function)

	hand_changed.emit()
	arrange_cards()


func get_primed_card() -> CardRoot:
	if hand_prime_controller == null:
		return null

	return hand_prime_controller.get_primed_card()


func get_index_of_card(card: CardRoot) -> int:
	return current_cards.find(card)


func is_card_in_hand(card: CardRoot) -> bool:
	return current_cards.has(card)


func is_full() -> bool:
	return current_cards.size() >= max_hand_size


func get_hand_size() -> int:
	return current_cards.size()


func get_cards() -> Array[CardRoot]:
	return current_cards.duplicate()


func arrange_cards() -> void:
	if hand_layout == null:
		return

	hand_layout.arrange_cards(current_cards)


func _on_prime_pressed() -> void:
	if hand_prime_controller == null:
		return

	hand_prime_controller.toggle_prime()
	_update_prime_button_state()


func _on_selected_card_changed(_card: CardRoot) -> void:
	_update_prime_button_state()


func _on_card_primed(card: CardRoot) -> void:
	card_primed.emit(card)
	_update_prime_button_state()


func _on_card_unprimed(card: CardRoot) -> void:
	card_unprimed.emit(card)
	_update_prime_button_state()


func _update_prime_button_state() -> void:
	if hand_buttons_root == null:
		return

	if hand_prime_controller == null:
		hand_buttons_root.set_prime_enabled(false)
		hand_buttons_root.set_prime_text("Prime")
		return

	if hand_prime_controller.can_unprime():
		hand_buttons_root.set_prime_enabled(true)
		hand_buttons_root.set_prime_text("Unprime")
		return

	hand_buttons_root.set_prime_enabled(
		hand_prime_controller.can_prime_selected_card()
	)

	hand_buttons_root.set_prime_text("Prime")
