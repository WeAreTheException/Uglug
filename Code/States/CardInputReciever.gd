extends Node
class_name CardInputReceiver

@export var card_state_machine: CardStateMachine
@export var card_input_listener: CardInputListener

func _ready() -> void:
	if card_input_listener == null:
		return

	card_input_listener.hovered.connect(_on_card_hovered)
	card_input_listener.hovered_off.connect(_on_card_hovered_off)

func _on_card_hovered(_card) -> void:
	pass

func _on_card_hovered_off(_card) -> void:
	pass
