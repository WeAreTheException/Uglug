extends Node
class_name BoardMutationRefresher

var board_query: BoardQuery = null


func setup(source_board_query: BoardQuery) -> void:
	board_query = source_board_query


func refresh_board_mutations() -> void:
	if board_query == null:
		return

	var cards := _get_board_cards()

	CardStats.begin_global_stat_feedback_collection()

	_begin_stat_batches(cards)

	for slot: Slot in board_query.get_all_slots():
		_refresh_slot(slot)

	_end_stat_batches(cards)

	CardStats.flush_global_stat_feedback_collection()


func _get_board_cards() -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	if board_query == null:
		return result

	for slot: Slot in board_query.get_all_slots():
		if slot == null:
			continue

		var card: CardRoot = slot.current_card

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if result.has(card):
			continue

		result.append(card)

	return result


func _begin_stat_batches(cards: Array[CardRoot]) -> void:
	for card: CardRoot in cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if card.stats == null:
			continue

		card.stats.begin_stat_refresh_batch()


func _end_stat_batches(cards: Array[CardRoot]) -> void:
	for card: CardRoot in cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if card.stats == null:
			continue

		card.stats.end_stat_refresh_batch()


func _refresh_slot(slot: Slot) -> void:
	if slot == null:
		return

	var card: CardRoot = slot.current_card

	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.refresh_board_effects()
