extends Node
class_name AntlerSyncManager

@export var delay_between_attacks: float = 0.25


func _ready() -> void:
	add_to_group("antler_sync_manager")

	GDSync.expose_node(self)
	GDSync.expose_func(run_antler_attack)


func sync_antler_attack(attacker_card_id: int, attack_plan: Array) -> void:
	if not GDSync.is_host():
		return

	print("SYNC ANTLER ATTACK attacker=", attacker_card_id, " plan=", attack_plan)

	GDSync.call_func_all(run_antler_attack, attacker_card_id, attack_plan)


func run_antler_attack(attacker_card_id: int, attack_plan: Array) -> void:
	var attacker := _find_card_by_id(attacker_card_id)

	if attacker == null:
		print("ANTLER SYNC blocked: attacker missing ", attacker_card_id)
		return

	var executor := attacker.get_node_or_null("AntlerAttackExecutor") as AntlerAttackExecutor

	if executor == null:
		print("ANTLER SYNC blocked: executor missing on attacker ", attacker_card_id)
		return

	for entry in attack_plan:
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		var is_direct := bool(entry.get("direct", false))
		var lane_id := int(entry.get("lane_id", -1))
		var target_card_id := int(entry.get("card_id", -1))

		if is_direct:
			var slot := _find_target_slot_for_attacker(attacker, lane_id)
			await executor.resolve_direct_attack(slot, _get_attack_anim(attacker))
		else:
			var target := _find_card_by_id(target_card_id)

			if target != null:
				await executor.resolve_card_attack(target, _get_attack_anim(attacker))
			else:
				print("ANTLER SYNC missing target card: ", target_card_id)

		if delay_between_attacks > 0.0:
			await get_tree().create_timer(delay_between_attacks).timeout


func _get_attack_anim(card: Card) -> Node:
	if card == null:
		return null

	if card.attack_handler == null:
		return null

	return card.attack_handler.attack_anim


func _find_card_by_id(card_id: int) -> Card:
	if card_id < 0:
		return null

	var cards := get_tree().get_nodes_in_group("cards")

	for node in cards:
		var found := node as Card

		if found == null:
			continue

		if found.multiplayer_card_id == card_id:
			return found

	return null


func _find_target_slot_for_attacker(attacker: Card, lane_id: int) -> NewSlots:
	if attacker == null:
		return null

	if attacker.current_slot == null:
		return null

	var front_slot := attacker.current_slot.opposing_slot

	if front_slot == null:
		return null

	var root := _get_slots_root(attacker)
	var enemy_slots := _get_slots_for_owner(root, front_slot.slot_owner)

	for slot in enemy_slots:
		if slot == null:
			continue

		if slot.lane_id == lane_id:
			return slot

	return null


func _get_slots_root(card: Card) -> Node:
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
