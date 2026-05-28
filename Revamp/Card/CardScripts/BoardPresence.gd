extends Node
class_name BoardPresence

var current_slot: Slot = null


func is_on_board() -> bool:
	return current_slot != null


func enter_slot(slot: Slot, card: CardRoot) -> bool:
	if slot == null:
		return false

	if card == null:
		return false

	if not slot.assign_card(card):
		return false

	current_slot = slot

	return true


func leave_slot(card: CardRoot) -> void:
	if current_slot == null:
		return

	if current_slot.current_card == card:
		current_slot.clear_card()

	current_slot = null
