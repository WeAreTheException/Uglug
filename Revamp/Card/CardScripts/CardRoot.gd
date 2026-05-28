extends Node2D
class_name CardRoot

signal hovered(card: CardRoot)
signal unhovered(card: CardRoot)
signal pressed(card: CardRoot)
signal released(card: CardRoot)

@export var test_data: CardData

@export var input: CardInput
@export var board_presence: BoardPresence
@export var stats: CardStats
@export var mutations: CardMutations
@export var card_art_root: CardArtRoot

var card_data: CardData = null
var card_name: String = ""


func _ready() -> void:
	_cache_children()
	_connect_input()

	if test_data != null:
		setup(test_data)


func setup(data: CardData) -> void:
	if data == null:
		return

	card_data = data
	card_name = data.name

	stats.setup_from_data(data)
	mutations.setup_from_data(data, self)
	card_art_root.setup_from_card(self)


func is_on_board() -> bool:
	return board_presence.is_on_board()


func get_current_slot() -> Slot:
	return board_presence.current_slot


func _cache_children() -> void:
	if input == null:
		input = get_node("Input/CardCollider") as CardInput

	if board_presence == null:
		board_presence = get_node("Core/BoardPresence") as BoardPresence

	if stats == null:
		stats = get_node("Core/CardStats") as CardStats

	if mutations == null:
		mutations = get_node("Core/CardMutations") as CardMutations

	if card_art_root == null:
		card_art_root = get_node("Visuals/CardArtRoot") as CardArtRoot


func _connect_input() -> void:
	input.hovered.connect(_on_input_hovered)
	input.unhovered.connect(_on_input_unhovered)
	input.pressed.connect(_on_input_pressed)
	input.released.connect(_on_input_released)


func _on_input_hovered() -> void:
	hovered.emit(self)


func _on_input_unhovered() -> void:
	unhovered.emit(self)


func _on_input_pressed() -> void:
	pressed.emit(self)


func _on_input_released() -> void:
	released.emit(self)
