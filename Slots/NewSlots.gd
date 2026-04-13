extends Area2D
class_name NewSlots

@export var opposing_slot: NewSlots

var current_card: Node2D = null

func is_empty() -> bool:
	return current_card == null

func can_accept_card(card: Node2D) -> bool:
	if card == null:
		return false

	return current_card == null or current_card == card

func assign_card(card: Node2D) -> bool:
	if not can_accept_card(card):
		print("Slot already occupied")
		return false

	current_card = card
	return true

func clear_card() -> void:
	current_card = null
