extends Area2D
class_name NewSlots

var current_card: Node2D = null

func is_empty() -> bool:
	return current_card == null

func assign_card(card: Node2D) -> void:
	current_card = card

func clear_card() -> void:
	current_card = null
