extends Mutation
class_name Antler

func get_attack_targets(card: Card, current_targets: Array[Card]) -> Array[Card]:
	var targets: Array[Card] = []

	if card == null:
		return targets

	if card.current_slot == null:
		return targets

	var front_slot = card.current_slot.opposing_slot

	if front_slot == null:
		return targets

	var left_slot = _find_slot_by_lane(card, front_slot.lane_id - 1, front_slot.slot_owner)
	var right_slot = _find_slot_by_lane(card, front_slot.lane_id + 1, front_slot.slot_owner)

	if _is_left_to_right(card):
		_add_slot_card(targets, left_slot)
		_add_slot_card(targets, right_slot)
	else:
		_add_slot_card(targets, right_slot)
		_add_slot_card(targets, left_slot)

	return targets


func _add_slot_card(targets: Array[Card], slot: Node) -> void:
	if slot == null:
		return

	if slot.current_card == null:
		return

	targets.append(slot.current_card)


func _find_slot_by_lane(card: Card, lane_id: int, slot_owner: int) -> Node:
	var root := card.get_tree().current_scene

	if root == null:
		return null

	var slots := _get_all_slots(root)

	for slot in slots:
		if slot.lane_id == lane_id and slot.slot_owner == slot_owner:
			return slot

	return null


func _get_all_slots(root: Node) -> Array[Node]:
	var found: Array[Node] = []
	_collect_slots(root, found)
	return found


func _collect_slots(node: Node, found: Array[Node]) -> void:
	if node is NewSlots:
		found.append(node)

	for child in node.get_children():
		_collect_slots(child, found)


func _is_left_to_right(card: Card) -> bool:
	if card.combat_manager != null:
		if card.combat_manager.has_method("is_current_attack_left_to_right"):
			return card.combat_manager.is_current_attack_left_to_right()

		if "attack_left_to_right" in card.combat_manager:
			return card.combat_manager.attack_left_to_right

	return true
