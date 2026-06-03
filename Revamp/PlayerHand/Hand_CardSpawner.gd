extends Node
class_name Hand_CardSpawner

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal hand_changed

var card_scene: PackedScene = null
var starting_cards: Array[CardData] = []
var hand_card_layer: Node2D = null

var max_hand_size: int = 7
var minimum_hand_size: int = 3

var current_cards: Array[CardRoot] = []


func configure(
	new_card_scene: PackedScene,
	new_starting_cards: Array[CardData],
	new_hand_card_layer: Node2D,
	new_max_hand_size: int,
	new_minimum_hand_size: int
) -> void:
	card_scene = new_card_scene
	starting_cards = new_starting_cards
	hand_card_layer = new_hand_card_layer
	max_hand_size = new_max_hand_size
	minimum_hand_size = new_minimum_hand_size


func spawn_starting_cards() -> void:
	for data in starting_cards:
		if is_full():
			return

		spawn_card(data)


func spawn_card(data: CardData) -> CardRoot:
	if data == null or card_scene == null or is_full():
		return null

	var card := card_scene.instantiate() as CardRoot

	if card == null:
		return null

	card.setup(data)

	if not add_card(card):
		card.queue_free()
		return null

	return card


func add_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if current_cards.has(card) or is_full():
		return false

	_move_card_to_hand_layer(card)
	current_cards.append(card)

	card_added.emit(card)
	hand_changed.emit()

	return true


func remove_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if not current_cards.has(card):
		return false

	current_cards.erase(card)

	card_removed.emit(card)
	hand_changed.emit()

	return true


func move_card_to_index(card: CardRoot, new_index: int) -> void:
	if card == null:
		return

	if not current_cards.has(card):
		return

	current_cards.erase(card)

	var clamped_index := clampi(new_index, 0, current_cards.size())
	current_cards.insert(clamped_index, card)

	hand_changed.emit()


func sort_cards(compare_function: Callable) -> void:
	current_cards.sort_custom(compare_function)
	hand_changed.emit()


func is_card_in_hand(card: CardRoot) -> bool:
	return current_cards.has(card)


func is_full() -> bool:
	return current_cards.size() >= max_hand_size


func get_hand_size() -> int:
	return current_cards.size()


func get_cards() -> Array[CardRoot]:
	return current_cards.duplicate()


func _move_card_to_hand_layer(card: CardRoot) -> void:
	if hand_card_layer == null:
		return

	if card.get_parent() == hand_card_layer:
		return

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand_card_layer.add_child(card)
	card.global_transform = saved_global_transform
