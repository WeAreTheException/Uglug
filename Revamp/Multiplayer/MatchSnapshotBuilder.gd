extends RefCounted
class_name MatchSnapshotBuilder


func build(root: MatchNetworkRoot) -> Dictionary:
	if root == null:
		return {}

	return {
		"match_state": _get_match_state(root),
		"round": _get_round(root),
		"active_owner": _get_active_owner(root),
		"controlled_owner": _get_controlled_owner(root),
		"score": _get_score(root),
		"hands": _build_hands(root),
		"board": _build_board(root),
		"draw_piles": _build_draw_piles(root)
	}


func _get_match_state(root: MatchNetworkRoot) -> int:
	if root.match_flow_root == null:
		return -1

	if root.match_flow_root.has_method("get_current_state"):
		return int(root.match_flow_root.get_current_state())

	var value = root.match_flow_root.get("current_state")
	if value == null:
		return -1

	return int(value)


func _get_round(root: MatchNetworkRoot) -> int:
	if root.match_flow_root == null:
		return -1

	if root.match_flow_root.has_method("get_round_number"):
		return int(root.match_flow_root.get_round_number())

	var value = root.match_flow_root.get("round_number")
	if value == null:
		return -1

	return int(value)


func _get_active_owner(root: MatchNetworkRoot) -> int:
	if root.turn_order_state == null:
		return -1

	return int(root.turn_order_state.get_active_owner())


func _get_controlled_owner(root: MatchNetworkRoot) -> int:
	if root.turn_order_state == null:
		return -1

	return int(root.turn_order_state.get_controlled_owner())


func _get_score(root: MatchNetworkRoot) -> int:
	if root.match_score_state == null:
		return 0

	return root.match_score_state.score


func _build_hands(root: MatchNetworkRoot) -> Dictionary:
	return {
		"player": _build_hand(root, SlotRow.SlotOwner.PLAYER),
		"opponent": _build_hand(root, SlotRow.SlotOwner.OPPONENT)
	}


func _build_hand(root: MatchNetworkRoot, owner: SlotRow.SlotOwner) -> Dictionary:
	if root.deck_system_root == null:
		return {
			"count": 0,
			"cards": []
		}

	var hand := root.deck_system_root.get_hand_for_owner(owner)
	var cards: Array = []

	if hand != null:
		for card: CardRoot in hand.get_cards():
			cards.append(_build_card(card))

	return {
		"count": cards.size(),
		"cards": cards
	}


func _build_board(root: MatchNetworkRoot) -> Array:
	var result: Array = []

	if root.slots_root == null:
		return result

	for slot: Slot in root.slots_root.get_all_slots():
		if slot == null:
			continue

		var owner := _get_canonical_slot_owner(root, slot)
		var slot_index := _get_canonical_slot_index(root, slot)
		var card_payload = null

		if slot.current_card != null:
			card_payload = _build_card(slot.current_card)

		result.append({
			"owner": int(owner),
			"slot_index": slot_index,
			"card": card_payload
		})

	return result

func _get_canonical_slot_owner(
	root: MatchNetworkRoot,
	slot: Slot
) -> SlotRow.SlotOwner:
	var local_owner := root.slots_root.get_owner_of_slot(slot)

	if root.is_host():
		return local_owner

	if local_owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER

func _build_draw_piles(root: MatchNetworkRoot) -> Dictionary:
	return {
		"player": _build_draw_pile(root, SlotRow.SlotOwner.PLAYER),
		"opponent": _build_draw_pile(root, SlotRow.SlotOwner.OPPONENT)
	}


func _get_canonical_slot_index(root: MatchNetworkRoot, slot: Slot) -> int:
	if root == null:
		return slot.slot_index

	if root.slots_root == null:
		return slot.slot_index

	if root.is_host():
		return slot.slot_index

	var local_owner := root.slots_root.get_owner_of_slot(slot)
	var slots := root.slots_root.get_slots_for_owner(local_owner)
	var max_index := 0

	for test_slot: Slot in slots:
		if test_slot == null:
			continue

		max_index = max(max_index, test_slot.slot_index)

	if max_index <= 0:
		return slot.slot_index

	return max_index + 1 - slot.slot_index
	
	
func _build_draw_pile(root: MatchNetworkRoot, owner: SlotRow.SlotOwner) -> Dictionary:
	if root.deck_system_root == null:
		return {
			"count": -1,
			"entries": []
		}

	var draw_pile := root.deck_system_root.get_draw_pile_for_owner(owner)

	if draw_pile == null:
		return {
			"count": -1,
			"entries": []
		}

	var entries: Array = []

	if draw_pile.has_method("get_entries"):
		entries = _clean_draw_entries(draw_pile.get_entries())

	return {
		"count": draw_pile.cards_left(),
		"entries": entries
	}


func _build_card(card: CardRoot) -> Dictionary:
	if card == null:
		return {}

	return {
		"card_id": _get_card_id(card),
		"runtime_id": card.get_runtime_id(),
		"name": card.card_name,
		"stats": _build_card_stats(card),
		"mutations": _build_card_mutations(card)
	}


func _get_card_id(card: CardRoot) -> String:
	if card.card_data == null:
		return ""

	if card.card_data.has_method("get_safe_card_id"):
		return card.card_data.get_safe_card_id()

	return card.card_data.card_id


func _build_card_stats(card: CardRoot) -> Dictionary:
	var stats := {}

	for key in [
		"damage",
		"current_damage",
		"health",
		"current_health",
		"max_health",
		"armor",
		"cost"
	]:
		var value = card.get(key)
		if value != null:
			stats[key] = value

	return stats


func _build_card_mutations(card: CardRoot) -> Array:
	var result: Array = []

	if card.mutations == null:
		return result

	if card.mutations.has_method("get_all_mutations"):
		for mutation in card.mutations.get_all_mutations():
			result.append(_get_mutation_id(mutation))

	elif card.mutations.has_method("get_inheritable_mutations"):
		for mutation in card.mutations.get_inheritable_mutations():
			result.append(_get_mutation_id(mutation))

	return result


func _get_mutation_id(mutation) -> String:
	if mutation == null:
		return ""

	if mutation.has_method("get_safe_mutation_id"):
		return mutation.get_safe_mutation_id()

	var id = mutation.get("mutation_id")
	if id == null:
		return ""

	return str(id)

func _clean_draw_entries(entries: Array) -> Array:
	var result: Array = []

	for entry in entries:
		if not entry is Dictionary:
			continue

		result.append({
			"card_id": str(entry.get("card_id", "")),
			"runtime_id": str(entry.get("runtime_id", "")),
			"inherited_mutation_ids": entry.get("inherited_mutation_ids", []).duplicate()
		})

	return result
