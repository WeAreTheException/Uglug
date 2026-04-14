extends Node
class_name CardInputReceiver

@export var card_state_machine: CardStateMachine
@export var card_input_listener: CardInputListener
@export var select_handler: SelectHandler
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
	if select_handler == null:
		return
	
	if card_root == null:
		return
	if card_root.current_slot != null:
		return

	select_handler.select_card(card_root)

func _on_card_released(_card) -> void:
	pass
