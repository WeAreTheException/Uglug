extends Node
class_name DrawPileInstance

var entries: Array[Dictionary] = []


func set_cards(new_cards: Array[CardData]) -> void:
	entries.clear()

	for i: int in range(new_cards.size()):
		var card_data: CardData = new_cards[i]

		if card_data == null:
			continue

		entries.append({
			"card_id": card_data.get_safe_card_id(),
			"runtime_id": _build_local_runtime_id(card_data, i),
			"card_data": card_data
		})


func set_entries(new_entries: Array) -> void:
	entries.clear()

	for entry in new_entries:
		if not entry is Dictionary:
			continue

		entries.append(entry.duplicate(true))


func draw_entry() -> Dictionary:
	if entries.is_empty():
		return {}

	return entries.pop_front()


func draw_card() -> CardData:
	var entry := draw_entry()

	if entry.is_empty():
		return null

	return entry.get("card_data", null) as CardData


func cards_left() -> int:
	return entries.size()


func is_empty() -> bool:
	return entries.is_empty()


func get_entries_debug() -> Array[Dictionary]:
	return entries.duplicate(true)


func get_cards_debug() -> Array[CardData]:
	var result: Array[CardData] = []

	for entry in entries:
		var card_data: CardData = entry.get("card_data", null) as CardData

		if card_data != null:
			result.append(card_data)

	return result


func clear_cards() -> void:
	entries.clear()


func _build_local_runtime_id(card_data: CardData, index: int) -> String:
	return (
		"local_draw_"
		+ card_data.get_safe_card_id()
		+ "_"
		+ str(index)
		+ "_"
		+ str(Time.get_ticks_usec())
	)
