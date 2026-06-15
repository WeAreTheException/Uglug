extends RefCounted
class_name PlacementRequestPayloadBuilder


func build_payload(
	board: SlotsRoot,
	placed_card: CardRoot,
	target_slot: Slot,
	owner: SlotRow.SlotOwner,
	sacrificed_cards: Array[CardRoot]
) -> Dictionary:
	if board == null:
		return {}

	if placed_card == null:
		return {}

	if target_slot == null:
		return {}

	return {
		"owner": owner,
		"placed_card_runtime_id": placed_card.get_runtime_id(),
		"target_slot_owner": board.get_owner_of_slot(target_slot),
		"target_slot_index": target_slot.slot_index,
		"sacrificed_card_runtime_ids": _get_runtime_ids(sacrificed_cards)
	}


func _get_runtime_ids(cards: Array[CardRoot]) -> Array[String]:
	var result: Array[String] = []

	for card: CardRoot in cards:
		if card == null:
			continue

		result.append(card.get_runtime_id())

	return result
