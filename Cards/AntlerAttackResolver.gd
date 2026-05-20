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
	var slots := _get_ordered_antler_slots()

	for slot in slots:
		if slot == null:
			continue

		var target := slot.current_card as Card

		var entry := {
			"lane_id": slot.lane_id,
			"direct": target == null,
			"card_id": target.multiplayer_card_id if target != null else -1
		}

		plan.append(entry)

	print("ANTLER ATTACK PLAN: ", plan)

	return plan


func _get_ordered_antler_slots() -> Array[NewSlots]:
	var slots: Array[NewSlots] = []

	if card == null:
		return slots

	if card.current_slot == null:
		return slots

	var front_slot := card.current_slot.opposing_slot

	if front_slot == null:
		return slots

	var root := _get_slots_root()

	if root == null:
		return slots

	var enemy_slots := _get_slots_for_owner(root, front_slot.slot_owner)

	var lower_lane_slot := _get_slot_by_lane(enemy_slots, front_slot.lane_id - 1)
	var higher_lane_slot := _get_slot_by_lane(enemy_slots, front_slot.lane_id + 1)

	if _card_owner_is_player_one():
		_add_slot(slots, lower_lane_slot)
		_add_slot(slots, higher_lane_slot)
	else:
		_add_slot(slots, higher_lane_slot)
		_add_slot(slots, lower_lane_slot)

	print("ANTLER owner peer=", card.owning_peer_id)
	print("ANTLER player one=", _get_player_one_id())
	print("ANTLER front lane=", front_slot.lane_id)
	print("ANTLER ordered slots=", slots)

	return slots


func _add_slot(slots: Array[NewSlots], slot: NewSlots) -> void:
	if slot == null:
		return

	slots.append(slot)


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


func _get_slot_by_lane(slots: Array[NewSlots], lane_id: int) -> NewSlots:
	for slot in slots:
		if slot == null:
			continue

		if slot.lane_id == lane_id:
			return slot

	return null


func _get_slots_root() -> Node:
	if card != null:
		if card.combat_manager != null:
			if card.combat_manager.slots_root != null:
				return card.combat_manager.slots_root

	return get_tree().current_scene


func _get_slots_for_owner(root: Node, wanted_owner: NewSlots.SlotOwner) -> Array[NewSlots]:
	var slots: Array[NewSlots] = []

	if root == null:
		return slots

	_collect_slots_for_owner(root, wanted_owner, slots)

	return slots


func _collect_slots_for_owner(node: Node, wanted_owner: NewSlots.SlotOwner, found: Array[NewSlots]) -> void:
	if node == null:
		return

	var slot := node as NewSlots

	if slot != null:
		if slot.slot_owner == wanted_owner:
			found.append(slot)

	for child in node.get_children():
		_collect_slots_for_owner(child, wanted_owner, found)


func _refresh_refs() -> void:
	if card == null:
		card = get_parent() as Card
