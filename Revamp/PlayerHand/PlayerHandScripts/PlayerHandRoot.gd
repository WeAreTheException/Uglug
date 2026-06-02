extends Node2D
class_name PlayerHandRoot

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal hand_changed

@export var card_scene: PackedScene
@export var starting_cards: Array[CardData]

@export var hand_cards_layer: Node2D
@export var drag_layer: Node2D
@export var hand_layout: HandLayout

@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3

var current_cards: Array[CardRoot] = []
var layout_ignored_card: CardRoot = null


func _ready() -> void:
	spawn_starting_cards()
	arrange_cards()


func spawn_starting_cards() -> void:
	for data in starting_cards:
		if current_cards.size() >= max_hand_size:
			return

		spawn_card(data)


func spawn_card(data: CardData) -> CardRoot:
	if data == null or card_scene == null or hand_cards_layer == null:
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


func remove_card(card: CardRoot) -> void:
	if card == null:
		return

	if not current_cards.has(card):
		return

	current_cards.erase(card)

	if layout_ignored_card == card:
		layout_ignored_card = null

	card_removed.emit(card)
	hand_changed.emit()

	arrange_cards()


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


func get_insert_index_from_global_x(global_x: float) -> int:
	if hand_layout == null:
		return current_cards.size()

	if current_cards.is_empty():
		return 0

	var total_width := hand_layout.card_spacing * float(current_cards.size() - 1)
	var start_x := -total_width / 2.0
	var local_x := global_x - hand_layout.global_position.x

	var index := int(round((local_x - start_x) / hand_layout.card_spacing))
	return clampi(index, 0, current_cards.size() - 1)


func set_layout_ignored_card(card: CardRoot) -> void:
	layout_ignored_card = card
	arrange_cards()


func clear_layout_ignored_card() -> void:
	layout_ignored_card = null
	arrange_cards()


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

	hand_layout.arrange_cards(current_cards, layout_ignored_card)
