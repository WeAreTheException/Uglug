extends Node2D
class_name PlayerHandRoot

signal card_added(card: CardRoot)
signal card_removed(card: CardRoot)
signal card_selected(card: CardRoot)
signal card_deselected(card: CardRoot)
signal hand_changed

@export var card_scene: PackedScene
@export var starting_cards: Array[CardData]

@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3

@export var hand_layout: Node

var current_cards: Array[CardRoot] = []
var selected_card: CardRoot = null


func _ready() -> void:
	print("PLAYER HAND READY")
	print("card_scene = ", card_scene)
	print("starting_cards = ", starting_cards.size())
	print("hand_layout = ", hand_layout)

	spawn_starting_cards()
	arrange_cards()


func spawn_starting_cards() -> void:
	for data in starting_cards:
		if current_cards.size() >= max_hand_size:
			return

		spawn_card(data)


func spawn_card(data: CardData) -> CardRoot:
	if data == null:
		print("SPAWN BLOCKED: data is null")
		return null

	if card_scene == null:
		print("SPAWN BLOCKED: card_scene is null")
		return null

	if is_full():
		print("SPAWN BLOCKED: hand is full")
		return null

	var card := card_scene.instantiate() as CardRoot

	if card == null:
		print("SPAWN BLOCKED: card_scene root is not CardRoot")
		return null

	add_child(card)
	card.setup(data)

	print("SPAWNED CARD: ", card.card_name, " at ", card.global_position)

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

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	card_added.emit(card)
	hand_changed.emit()

	arrange_cards()


func remove_card(card: CardRoot) -> void:
	if card == null:
		return

	if not current_cards.has(card):
		return

	current_cards.erase(card)

	if selected_card == card:
		clear_selected_card()

	card_removed.emit(card)
	hand_changed.emit()

	arrange_cards()


func select_card(card: CardRoot) -> void:
	if card == null:
		return

	if not current_cards.has(card):
		return

	if selected_card == card:
		return

	if selected_card != null:
		card_deselected.emit(selected_card)

	selected_card = card
	card_selected.emit(selected_card)


func clear_selected_card() -> void:
	if selected_card == null:
		return

	var old_card := selected_card
	selected_card = null

	card_deselected.emit(old_card)


func is_full() -> bool:
	return current_cards.size() >= max_hand_size


func get_hand_size() -> int:
	return current_cards.size()


func get_cards() -> Array[CardRoot]:
	return current_cards.duplicate()


func arrange_cards() -> void:
	print("ARRANGE CALLED. hand_layout = ", hand_layout)

	if hand_layout == null:
		print("ARRANGE BLOCKED: hand_layout is null")
		return

	if hand_layout.has_method("arrange_cards"):
		print("ARRANGE USING HAND LAYOUT")
		hand_layout.arrange_cards(current_cards)
	else:
		print("ARRANGE BLOCKED: hand_layout has no arrange_cards method")


func _on_card_pressed(card: CardRoot) -> void:
	select_card(card)
