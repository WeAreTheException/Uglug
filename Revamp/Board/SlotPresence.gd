extends Node
class_name SlotPresence

var slot: Slot = null
var current_card: CardRoot = null


func setup(source_slot: Slot) -> void:
	slot = source_slot


func is_empty() -> bool:
	return current_card == null


func assign_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if current_card != null:
		return false

	current_card = card

	return true


func clear_card() -> void:
	current_card = null


func get_current_card() -> CardRoot:
	return current_card
