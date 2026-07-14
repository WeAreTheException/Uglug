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

	print("BOARD ENTER | card=", card.card_name, " slot=", slot.name)

	_try_refresh_board_mutations(card)

	return true


func leave_slot(card: CardRoot) -> void:
	if current_slot == null:
		return

	print("BOARD LEAVE | card=", card.card_name if card != null else "null", " slot=", current_slot.name)

	_notify_left_board(card)

	var old_slots_root: SlotsRoot = null

	if card != null:
		old_slots_root = card.slots_root

	if current_slot.current_card == card:
		current_slot.clear_card()

	current_slot = null

	_try_refresh_board_mutations_from_root(old_slots_root)

	current_slot = null

	_try_refresh_board_mutations_from_root(old_slots_root)


func _try_refresh_board_mutations(card: CardRoot) -> void:
	if card == null:
		return

	_try_refresh_board_mutations_from_root(card.slots_root)


func _try_refresh_board_mutations_from_root(slots_root: SlotsRoot) -> void:
	if slots_root == null:
		return

	if _should_skip_local_network_aura_refresh():
		return

	slots_root.refresh_board_mutations()


func _should_skip_local_network_aura_refresh() -> bool:
	if not Engine.has_singleton("GDSync"):
		return false

	return not GDSync.is_host()


func _notify_left_board(card: CardRoot) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_left_board()
