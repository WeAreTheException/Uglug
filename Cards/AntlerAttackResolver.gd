extends Node
class_name AntlerAttackResolver

@export var delay_between_attacks: float = 0.25

var card: Card = null
var attack_handler: AttackHandler = null
var executor: AntlerAttackExecutor = null


func _ready() -> void:
	_refresh_refs()

	GDSync.expose_node(self)
	GDSync.expose_func(run_synced_antler_attack)


func resolve() -> bool:
	_refresh_refs()

	if card == null:
		return false

	if executor == null:
		return false

	if not has_antler():
		return false

	if not GDSync.is_host():
		print("Antler waiting for host synced attack")
		return true

	var attack_plan := _build_attack_plan()

	print("HOST SYNCING ANTLER PLAN: ", attack_plan)

	GDSync.call_func_all(run_synced_antler_attack, attack_plan)

	return true


func run_synced_antler_attack(attack_plan: Array) -> void:
	_refresh_refs()

	if card == null:
		return

	if executor == null:
		return

	print("RUN SYNCED ANTLER peer=", int(GDSync.get_client_id()), " owner=", card.owning_peer_id, " plan=", attack_plan)

	for entry in attack_plan:
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		var is_direct := bool(entry.get("direct", false))
		var lane_id := int(entry.get("lane_id", -1))
		var target_card_id := int(entry.get("card_id", -1))

		if is_direct:
			var direct_slot := _find_target_slot_by_lane(lane_id)
			await executor.resolve_direct_attack(direct_slot, attack_handler.attack_anim if attack_handler != null else null)
		else:
			var target_card := _find_card_by_multiplayer_id(target_card_id)

			if target_card != null:
				await executor.resolve_card_attack(target_card, attack_handler.attack_anim if attack_handler != null else null)
			else:
				print("ANTLER target card missing on this peer: ", target_card_id)

		if delay_between_attacks > 0.0:
			await get_tree().create_timer(delay_between_attacks).timeout


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

	return plan


func _get_ordered_antler_slots() -> Array[NewSlots]:
	var slots: Array[NewSlots] = []

	_refresh_refs()

	if card == null:
		return slots

	if card.current_slot == null:
		return slots

	var front_slot := card.current_slot.opposing_slot
	if front_slot == null:
		return slots

	var enemy_slots := _get_slots_for_owner(_get_slots_root(), front_slot.slot_owner)

	var lower_lane_slot := _get_slot_by_lane(enemy_slots, front_slot.lane_id - 1)
	var higher_lane_slot := _get_slot_by_lane(enemy_slots, front_slot.lane_id + 1)

	if _card_owner_is_player_one():
		_add_slot(slots, lower_lane_slot)
		_add_slot(slots, higher_lane_slot)
	else:
		_add_slot(slots, higher_lane_slot)
		_add_slot(slots, lower_lane_slot)

	print("ANTLER PLAN owner peer=", card.owning_peer_id)
	print("ANTLER PLAN player one=", _get_player_one_id())
	print("ANTLER PLAN front lane=", front_slot.lane_id)
	print("ANTLER PLAN final slots=", slots)

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


func _find_target_slot_by_lane(lane_id: int) -> NewSlots:
	_refresh_refs()

	if card == null:
		return null

	if card.current_slot == null:
		return null

	var front_slot := card.current_slot.opposing_slot
	if front_slot == null:
		return null

	var root := _get_slots_root()
	if root == null:
		return null

	var enemy_slots := _get_slots_for_owner(root, front_slot.slot_owner)

	return _get_slot_by_lane(enemy_slots, lane_id)


func _find_card_by_multiplayer_id(card_id: int) -> Card:
	if card_id < 0:
		return null

	var tree := get_tree()

	if tree == null:
		return null

	var cards := tree.get_nodes_in_group("cards")

	for node in cards:
		var found_card := node as Card

		if found_card == null:
			continue

		if found_card.multiplayer_card_id == card_id:
			return found_card

	return null


func _get_slot_by_lane(slots: Array[NewSlots], lane_id: int) -> NewSlots:
	for slot in slots:
		if slot == null:
			continue

		if slot.lane_id == lane_id:
			return slot

	return null


func _get_slots_root() -> Node:
	_refresh_refs()

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

	if attack_handler == null and card != null:
		attack_handler = card.attack_handler

	if executor == null and card != null:
		executor = card.get_node_or_null("AntlerAttackExecutor") as AntlerAttackExecutor
