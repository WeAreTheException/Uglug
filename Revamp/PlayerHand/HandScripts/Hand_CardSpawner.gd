extends Node
class_name Hand_CardSpawner

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal hand_changed

@export var enable_debug_spawn_test: bool = false
@export var debug_spawn_card: CardData
@export var debug_normal_spawn_key: Key = KEY_Y
@export var debug_effect_spawn_key: Key = KEY_U

var card_scene: PackedScene = null
var starting_cards: Array[CardData] = []
var card_parent: Node2D = null
var max_hand_size: int = 7
var minimum_hand_size: int = 3

var store := HandSpawnerStoreHelper.new()
var factory := HandCardFactoryHelper.new()


func configure(
	new_card_scene: PackedScene,
	new_starting_cards: Array[CardData],
	new_card_parent: Node2D,
	new_max_hand_size: int,
	new_minimum_hand_size: int
) -> void:
	card_scene = new_card_scene
	starting_cards = new_starting_cards
	card_parent = new_card_parent
	max_hand_size = new_max_hand_size
	minimum_hand_size = new_minimum_hand_size


func _input(event: InputEvent) -> void:
	if not enable_debug_spawn_test:
		return

	if debug_spawn_card == null:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_normal_spawn_key:
			spawn_card(debug_spawn_card)

		if event.keycode == debug_effect_spawn_key:
			spawn_card_ignoring_limit(debug_spawn_card)


func spawn_starting_cards() -> void:
	for data in starting_cards:
		spawn_card(data)


func spawn_card(data: CardData) -> CardRoot:
	if store.size() >= max_hand_size:
		return null

	return _spawn_card_internal(data)


func spawn_card_ignoring_limit(data: CardData) -> CardRoot:
	return _spawn_card_internal(data)

func spawn_card_with_runtime_id(
	data: CardData,
	runtime_id: String
) -> CardRoot:
	var card := spawn_card(data)

	if card != null:
		card.set_runtime_id(runtime_id)

	return card


func spawn_card_ignoring_limit_with_runtime_id(
	data: CardData,
	runtime_id: String
) -> CardRoot:
	var card := spawn_card_ignoring_limit(data)

	if card != null:
		card.set_runtime_id(runtime_id)

	return card
	

func add_card(card: CardRoot) -> void:
	if not store.add_card(card):
		return

	card_added.emit(card)
	hand_changed.emit()


func remove_card(card: CardRoot) -> void:
	if not store.remove_card(card):
		return

	card_removed.emit(card)
	hand_changed.emit()


func move_card_to_index(card: CardRoot, index: int) -> void:
	if store.move_card_to_index(card, index):
		hand_changed.emit()


func sort_cards(sorter: Callable) -> void:
	store.sort_cards(sorter)
	hand_changed.emit()


func get_cards() -> Array[CardRoot]:
	return store.get_cards()


func is_card_in_hand(card: CardRoot) -> bool:
	return store.has_card(card)


func get_card_count() -> int:
	return store.size()


func _spawn_card_internal(data: CardData) -> CardRoot:
	if data == null:
		return null

	var card: CardRoot = factory.create_card(card_scene, data, card_parent)

	if card == null:
		return null

	add_card(card)
	return card

func clear_cards(free_cards: bool = true) -> void:
	var current_cards := store.get_cards()

	store.clear()

	for card: CardRoot in current_cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		card_removed.emit(card)

		if free_cards:
			card.queue_free()

	hand_changed.emit()
