extends Node
class_name Hand_CardSpawner

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal hand_changed

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


func spawn_starting_cards() -> void:
	for data in starting_cards:
		spawn_card(data)


func spawn_card(data: CardData) -> CardRoot:
	if store.size() >= max_hand_size:
		return null

	var card := factory.create_card(card_scene, data, card_parent)

	if card == null:
		return null

	add_card(card)
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
