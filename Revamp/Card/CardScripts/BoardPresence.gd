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

	if card.slots_root != null:
		card.slots_root.refresh_board_mutations()

	return true


func leave_slot(card: CardRoot) -> void:
	if current_slot == null:
		return

	_notify_left_board(card)

	var old_slots_root: SlotsRoot = null

	if card != null:
		old_slots_root = card.slots_root

	if current_slot.current_card == card:
		current_slot.clear_card()

	current_slot = null

	if old_slots_root != null:
		old_slots_root.refresh_board_mutations()


func _notify_left_board(card: CardRoot) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_left_board()
