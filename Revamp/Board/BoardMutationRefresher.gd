extends Node
class_name BoardRefreshCoordinator

var board_query: BoardQuery = null


func setup(source_board_query: BoardQuery) -> void:
	board_query = source_board_query


func refresh_board() -> void:
	refresh_board_effects()


func refresh_board_effects() -> void:
	if board_query == null:
		return

	for slot in board_query.get_all_slots():
		_refresh_slot_effects(slot)

	for slot in board_query.get_all_slots():
		_refresh_card_board_effects(slot)


func refresh_board_mutations() -> void:
	refresh_board_effects()


func _refresh_slot_effects(slot: Slot) -> void:
	if slot == null:
		return

	slot.refresh_slot_effects()


func _refresh_card_board_effects(slot: Slot) -> void:
	if slot == null:
		return

	var card := slot.current_card

	if card == null:
		return

	if card.mutations == null:
		return

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.refresh_board_effect(runtime)
