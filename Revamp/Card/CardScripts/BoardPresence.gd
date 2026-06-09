extends Node
class_name BoardPresence

var card: CardRoot = null
var current_slot: Slot = null

func setup(source_card: CardRoot) -> void:
	card = source_card

func is_on_board() -> bool:
	return current_slot != null

func enter_slot(slot: Slot) -> bool:
	if card == null or slot == null:
		return false
	if current_slot == slot:
		return true
	if current_slot != null:
		leave_slot(CardLeaveReason.MOVED)
	if not slot.assign_card(card):
		return false
	current_slot = slot
	_refresh_board()
	return true

func leave_slot(reason: String = CardLeaveReason.NONE) -> void:
	if current_slot == null:
		return
	_notify_left_board(reason)
	var old_root := card.slots_root if card != null else null
	if current_slot.current_card == card:
		current_slot.clear_card()
	current_slot = null
	if old_root != null:
		old_root.refresh_board_effects()

func _notify_left_board(_reason: String) -> void:
	if card == null or card.mutations == null:
		return
	for runtime in card.mutations.get_all_runtimes():
		if runtime == null or runtime.mutation == null:
			continue
		runtime.mutation.on_left_board(runtime)

func _refresh_board() -> void:
	if card != null and card.slots_root != null:
		card.slots_root.refresh_board_effects()
