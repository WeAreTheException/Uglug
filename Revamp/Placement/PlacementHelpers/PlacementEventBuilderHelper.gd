extends RefCounted
class_name PlacementEventBuilderHelper


func build_event(
	board: SlotsRoot,
	card: CardRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner
) -> Dictionary:
	if board == null or card == null or slot == null:
		return {}

	return {
		"card": card,
		"card_data": card.card_data,
		"slot": slot,
		"slot_index": slot.slot_index,
		"slot_owner": board.get_owner_of_slot(slot),
		"placing_owner": owner,
		"opposing_slot": board.get_opposing_slot(slot),
		"adjacent_enemy_slots": board.get_adjacent_enemy_slots(slot)
	}
