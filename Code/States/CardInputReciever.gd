extends Node
class_name CardInputReceiver

@export var card_state_machine: CardStateMachine

func connect_card_signals(listener: CardInputListener) -> void:
	if listener == null:
		return

	listener.hovered.connect(_on_card_hovered)
	listener.hovered_off.connect(_on_card_hovered_off)

func _on_card_hovered(_card) -> void:
	pass

func _on_card_hovered_off(_card) -> void:
	pass
