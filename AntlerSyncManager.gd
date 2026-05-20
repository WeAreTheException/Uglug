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
		var target_card_id := int(entry.get("card_id", -1))
		var offset := int(entry.get("offset", 0))

		if is_direct:
			var direct_slot := _find_direct_slot_by_pair_offset(attacker, offset)
			await executor.resolve_direct_attack(direct_slot, _get_attack_anim(attacker))
		else:
			var target := _find_card_by_id(target_card_id)

			if target != null:
				await executor.resolve_card_attack(target, _get_attack_anim(attacker))
			else:
				print("ANTLER SYNC missing target card: ", target_card_id)

		if delay_between_attacks > 0.0:
			await get_tree().create_timer(delay_between_attacks).timeout


func _find_direct_slot_by_pair_offset(attacker: Card, offset: int) -> NewSlots:
	if attacker == null:
		return null

	if attacker.current_slot == null:
		return null

	var front_slot := attacker.current_slot.opposing_slot
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
