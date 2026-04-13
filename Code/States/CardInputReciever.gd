extends Node
class_name CardInputReceiver

@export var card_state_machine: CardStateMachine
@export var card_input_listener: CardInputListener
@export var card_drag_handler: CardDragHandler
@export var card_root: Card

var is_hovered: bool = false

func _ready() -> void:
	if card_input_listener == null:
		return

	card_input_listener.hovered.connect(_on_card_hovered)
	card_input_listener.hovered_off.connect(_on_card_hovered_off)
	card_input_listener.pressed.connect(_on_card_pressed)
	card_input_listener.released.connect(_on_card_released)

func _on_card_hovered(_card) -> void:
	is_hovered = true

func _on_card_hovered_off(_card) -> void:
	is_hovered = false

func _on_card_pressed(_card) -> void:
	if card_drag_handler == null:
		return
	if card_root == null:
		return

	card_drag_handler.start_drag(card_root)

func _on_card_released(_card) -> void:
	if card_drag_handler == null:
		return

	card_drag_handler.stop_drag()
