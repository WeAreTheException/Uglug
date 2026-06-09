extends Node
class_name BoardMutationRefresher

var board_query: BoardQuery = null


func setup(source_board_query: BoardQuery) -> void:
	board_query = source_board_query


func refresh_board_mutations() -> void:
	if board_query == null:
		return

	for slot in board_query.get_all_slots():
		_refresh_slot(slot)


func _refresh_slot(slot: Slot) -> void:
	if slot == null:
		return

	var card := slot.current_card

	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.refresh_board_effects()
