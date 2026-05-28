extends Node2D
class_name Card

signal hovered(card: Card)
signal unhovered(card: Card)
signal pressed(card: Card)
signal released(card: Card)

@export var test_data: CardData

@export var input: CardInput
@export var board_presence: BoardPresence
@export var stats: CardStats
@export var mutations: CardMutations
@export var card_art: CardArt

var card_data: CardData = null
var card_name: String = ""


func _ready() -> void:
	_cache_children()
	_connect_input()

	if test_data != null:
		setup(test_data)


func _cache_children() -> void:
	if input == null:
		input = get_node_or_null("Input/CardCollider") as CardInput

	if board_presence == null:
		board_presence = get_node_or_null("Core/BoardPresence") as BoardPresence

	if stats == null:
		stats = get_node_or_null("Core/CardStats") as CardStats

	if mutations == null:
		mutations = get_node_or_null("Core/CardMutations") as CardMutations

	if card_art == null:
		card_art = get_node_or_null("Visuals/CardArt") as CardArt


func _connect_input() -> void:
	if input == null:
		return

	input.hovered.connect(_on_input_hovered)
	input.unhovered.connect(_on_input_unhovered)
	input.pressed.connect(_on_input_pressed)
	input.released.connect(_on_input_released)


func setup(data: CardData) -> void:
	if data == null:
		return

	card_data = data
	card_name = data.name

	if stats != null:
		stats.setup_from_data(data)

	if mutations != null:
		mutations.setup_from_data(data)

	if card_art != null:
		card_art.setup_from_card(self)


func is_on_board() -> bool:
	return board_presence != null and board_presence.is_on_board()


func get_current_slot() -> Slot:
	if board_presence == null:
		return null

	return board_presence.current_slot


func _on_input_hovered() -> void:
	hovered.emit(self)


func _on_input_unhovered() -> void:
	unhovered.emit(self)


func _on_input_pressed() -> void:
	pressed.emit(self)


func _on_input_released() -> void:
	released.emit(self)
