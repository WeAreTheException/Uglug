extends Node
class_name AntlerAttackResolver

var card: Card = null


func resolve() -> bool:
	_refresh_refs()

	if card == null:
		return false

	if not has_antler():
		return false

	if not GDSync.is_host():
		print("Antler handled by host sync")
		return true

	var manager := _get_sync_manager()
	if manager == null:
		print("ANTLER blocked: AntlerSyncManager missing")
		return true

	var attack_plan := _build_attack_plan()
	manager.sync_antler_attack(card.multiplayer_card_id, attack_plan)

	return true


func has_antler() -> bool:
	_refresh_refs()

	if card == null:
		return false

	for mutation in card.base_mutations:
		if mutation is Antler:
			return true

	for mutation in card.additional_mutations:
		if mutation is Antler:
			return true

	return false


func _build_attack_plan() -> Array:
	var plan: Array = []

	var entries := _get_ordered_antler_slots_with_offsets()

	for entry in entries:
		var slot := entry["slot"] as NewSlots
		var offset := int(entry["offset"])

		if slot == null:
			continue

		var target := slot.current_card as Card

		plan.append({
			"offset": offset,
			"direct": target == null,
			"card_id": target.multiplayer_card_id if target != null else -1
		})

	print("ANTLER ATTACK PLAN: ", plan)

	return plan


func _get_ordered_antler_slots_with_offsets() -> Array:
	var result: Array = []

	if card == null:
		return result

	if card.current_slot == null:
		return result

	var front_slot := card.current_slot.opposing_slot
	if front_slot == null:
		return result

	var left_slot := _get_adjacent_slot_from_pair(front_slot, -1)
	var right_slot := _get_adjacent_slot_from_pair(front_slot, 1)

	if _card_owner_is_player_one():
		_add_slot_entry(result, right_slot, 1)
		_add_slot_entry(result, left_slot, -1)
	else:
		_add_slot_entry(result, left_slot, -1)
		_add_slot_entry(result, right_slot, 1)

	print("ANTLER owner peer=", card.owning_peer_id)
	print("ANTLER player one=", _get_player_one_id())
	print("ANTLER front slot=", front_slot)
	print("ANTLER ordered pair slots=", result)

	return result


func _get_adjacent_slot_from_pair(front_slot: NewSlots, offset: int) -> NewSlots:
	if front_slot == null:
		return null

	var front_pair := front_slot.get_parent()
	if front_pair == null:
		return null

	var pairs_root := front_pair.get_parent()
	if pairs_root == null:
		return null

	var pairs := pairs_root.get_children()
	var front_index := pairs.find(front_pair)

	if front_index == -1:
		return null

	var target_index := front_index + offset

	if target_index < 0 or target_index >= pairs.size():
		return null

	var target_pair := pairs[target_index]
	return _get_slot_in_pair_for_owner(target_pair, front_slot.slot_owner)


func _get_slot_in_pair_for_owner(pair_node: Node, wanted_owner: NewSlots.SlotOwner) -> NewSlots:
	if pair_node == null:
		return null

	for child in pair_node.get_children():
		var slot := child as NewSlots

		if slot != null:
			if slot.slot_owner == wanted_owner:
				return slot

	return null


func _add_slot_entry(result: Array, slot: NewSlots, offset: int) -> void:
	if slot == null:
		return

	result.append({
		"slot": slot,
		"offset": offset
	})


func _card_owner_is_player_one() -> bool:
	return card.owning_peer_id == _get_player_one_id()


func _get_player_one_id() -> int:
	var tree := get_tree()
	if tree == null:
		return -1

	var turn_manager := tree.get_first_node_in_group("turn_manager") as TurnManager
	if turn_manager == null:
		return -1

	return turn_manager.player_one_id


func _get_sync_manager() -> AntlerSyncManager:
	var tree := get_tree()
	if tree == null:
		return null

	return tree.get_first_node_in_group("antler_sync_manager") as AntlerSyncManager


func _refresh_refs() -> void:
	if card == null:
		card = get_parent() as Card
