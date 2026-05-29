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
@export var card_visuals_root: CardVisualsRoot
@export var card_feedback: CardFeedback
@export var attack: Attack

var slots_root: SlotsRoot = null

var card_data: CardData = null
var card_name: String = ""


func _ready() -> void:
	_connect_input()
	setup_actions()

	if test_data != null:
		setup(test_data)


func setup(data: CardData) -> void:
	if data == null:
		return

	card_data = data
	card_name = data.name

	if stats != null:
		stats.setup_from_data(data)

	if mutations != null:
		mutations.setup_from_data(data, self)

	if card_visuals_root != null:
		card_visuals_root.setup_from_card(self)


func setup_board_context(new_slots_root: SlotsRoot) -> void:
	slots_root = new_slots_root
	setup_actions()


func setup_actions() -> void:
	if attack != null:
		attack.setup(self, slots_root)


func is_on_board() -> bool:
	if board_presence == null:
		return false

	return board_presence.is_on_board()


func get_current_slot() -> Slot:
	if board_presence == null:
		return null

	return board_presence.current_slot


func _connect_input() -> void:
	if input == null:
		return

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
