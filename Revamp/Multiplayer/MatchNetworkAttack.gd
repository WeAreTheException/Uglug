extends Node
class_name MatchNetworkAttack

@export var print_debug: bool = false

var root: MatchNetworkRoot = null
var connected_death_handlers: Array[Die] = []


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func build_attack_payload(
	attacker_card: CardRoot,
	expected_owner: SlotRow.SlotOwner
) -> Dictionary:
	if attacker_card == null:
		print("ATTACK PAYLOAD FAILED: attacker_card missing")
		return {}

	if not is_instance_valid(attacker_card):
		print("ATTACK PAYLOAD FAILED: attacker_card invalid")
		return {}

	var attacker_slot := attacker_card.get_current_slot()

	if attacker_slot == null:
		print("ATTACK PAYLOAD FAILED: attacker has no slot")
		return {}

	if root == null:
		print("ATTACK PAYLOAD FAILED: root missing")
		return {}

	if root.slots_root == null:
		print("ATTACK PAYLOAD FAILED: slots_root missing")
		return {}

	var actual_owner := root.slots_root.get_owner_of_slot(attacker_slot)

	if actual_owner != expected_owner:
		print(
			"ATTACK PAYLOAD FAILED: owner mismatch | expected=",
			root.get_owner_name(expected_owner),
			" actual=",
			root.get_owner_name(actual_owner)
		)
		return {}

	var payload := {
		"attacker_card_runtime_id": attacker_card.get_runtime_id(),
		"attacker_owner": int(actual_owner),
		"attacker_slot_index": attacker_slot.slot_index
	}

	if print_debug:
		print("ATTACK PAYLOAD BUILT: ", payload)

	return payload

func run_confirmed_attack(payload: Dictionary) -> void:
	var runtime_id: String = payload.get("attacker_card_runtime_id", "")

	var card := root.slots_root.find_card_by_runtime_id(runtime_id)

	if card == null:
		print("CONFIRMED ATTACK FAILED: attacker missing")
		return

	if card.attack == null:
		print("CONFIRMED ATTACK FAILED: attack missing")
		return

	_connect_attack_signals(card.attack)
	_connect_board_death_signals()

	if print_debug:
		print("CONFIRMED ATTACK EXECUTING: ", payload)

	_broadcast_attack_sequence_started(payload)

	await card.attack.perform_attack()
	
	_broadcast_attack_sequence_finished(payload)

	_disconnect_board_death_signals()
	_disconnect_attack_signals(card.attack)
	
func is_valid_attack_payload(
	payload: Dictionary,
	expected_owner: SlotRow.SlotOwner
) -> bool:
	if root == null:
		print("ATTACK VALIDATION FAILED: root missing")
		return false

	if root.match_flow_root == null:
		print("ATTACK VALIDATION FAILED: match_flow_root missing")
		return false

	if root.match_flow_root.current_state != MatchFlowRoot.MatchState.COMBAT:
		print("ATTACK VALIDATION FAILED: wrong phase")
		return false

	if payload.is_empty():
		print("ATTACK VALIDATION FAILED: payload empty")
		return false

	var runtime_id: String = payload.get("attacker_card_runtime_id", "")
	var owner: SlotRow.SlotOwner = int(payload.get("attacker_owner", -1)) as SlotRow.SlotOwner
	var slot_index: int = int(payload.get("attacker_slot_index", -1))

	if runtime_id.strip_edges() == "":
		print("ATTACK VALIDATION FAILED: runtime id missing")
		return false

	if owner != expected_owner:
		print("ATTACK VALIDATION FAILED: owner mismatch")
		return false

	if root.slots_root == null:
		print("ATTACK VALIDATION FAILED: slots_root missing")
		return false

	var slot := root.slots_root.get_slot(owner, slot_index)

	if slot == null:
		print("ATTACK VALIDATION FAILED: slot missing")
		return false

	var card := slot.current_card

	if card == null:
		print("ATTACK VALIDATION FAILED: card missing from slot")
		return false

	if not is_instance_valid(card):
		print("ATTACK VALIDATION FAILED: card invalid")
		return false

	if card.get_runtime_id() != runtime_id:
		print("ATTACK VALIDATION FAILED: runtime id mismatch")
		return false

	if card.get_current_slot() != slot:
		print("ATTACK VALIDATION FAILED: card slot mismatch")
		return false

	if card.attack == null:
		print("ATTACK VALIDATION FAILED: attack missing")
		return false

	if card.stats == null:
		print("ATTACK VALIDATION FAILED: stats missing")
		return false

	if card.stats.get_attack() <= 0:
		print("ATTACK VALIDATION FAILED: attack <= 0")
		return false

	if card.stats.is_dead():
		print("ATTACK VALIDATION FAILED: card dead")
		return false

	if card.die != null and card.die.is_unavailable_for_combat():
		print("ATTACK VALIDATION FAILED: card unavailable")
		return false

	if print_debug:
		print("ATTACK VALIDATION PASSED: ", payload)
	return true


func _connect_attack_signals(attack: Attack) -> void:
	if attack == null:
		return

	if not attack.attack_started.is_connected(_on_attack_started):
		attack.attack_started.connect(_on_attack_started)

	if not attack.attack_hit.is_connected(_on_attack_hit):
		attack.attack_hit.connect(_on_attack_hit)

	if not attack.attack_finished.is_connected(_on_attack_finished):
		attack.attack_finished.connect(_on_attack_finished)


func _disconnect_attack_signals(attack: Attack) -> void:
	if attack == null:
		return

	if attack.attack_started.is_connected(_on_attack_started):
		attack.attack_started.disconnect(_on_attack_started)

	if attack.attack_hit.is_connected(_on_attack_hit):
		attack.attack_hit.disconnect(_on_attack_hit)

	if attack.attack_finished.is_connected(_on_attack_finished):
		attack.attack_finished.disconnect(_on_attack_finished)


func _on_attack_started(context: AttackContext) -> void:
	_broadcast_attack_started(_build_event_payload(context))


func _on_attack_hit(context: AttackContext) -> void:
	_broadcast_attack_hit(_build_event_payload(context))


func _on_attack_finished(context: AttackContext) -> void:
	_broadcast_attack_finished(_build_event_payload(context))
	_broadcast_all_board_card_stats()


func _build_event_payload(context: AttackContext) -> Dictionary:
	if context == null:
		return {}

	var attacker_id := ""
	var target_id := ""
	var attacker_slot_index := -1
	var target_slot_index := -1

	if context.attacker_card != null and is_instance_valid(context.attacker_card):
		attacker_id = context.attacker_card.get_runtime_id()

	if context.attacker_slot != null:
		attacker_slot_index = context.attacker_slot.slot_index

	if context.target_slot != null:
		target_slot_index = context.target_slot.slot_index

		if context.target_slot.current_card != null:
			target_id = context.target_slot.current_card.get_runtime_id()

	return {
		"attacker_card_runtime_id": attacker_id,
		"attacker_owner": int(context.attacker_owner),
		"attacker_slot_index": attacker_slot_index,
		"target_owner": int(context.target_owner),
		"target_slot_index": target_slot_index,
		"target_card_runtime_id": target_id,
		"attack_event": context.get_attack_direction()
	}


func _broadcast_attack_sequence_started(payload: Dictionary) -> void:
	GDSync.call_func_all(root._receive_attack_sequence_started, payload)


func _broadcast_attack_started(payload: Dictionary) -> void:
	GDSync.call_func_all(root._receive_attack_started, payload)


func _broadcast_attack_hit(payload: Dictionary) -> void:
	GDSync.call_func_all(root._receive_attack_hit, payload)


func _broadcast_attack_finished(payload: Dictionary) -> void:
	GDSync.call_func_all(root._receive_attack_finished, payload)


func _broadcast_attack_sequence_finished(payload: Dictionary) -> void:
	GDSync.call_func_all(root._receive_attack_sequence_finished, payload)


func receive_attack_sequence_started(payload: Dictionary) -> void:
	if print_debug:
		print("ATTACK SEQUENCE STARTED RECEIVED: ", payload)


func receive_attack_started(payload: Dictionary) -> void:
	if print_debug:
		print("ATTACK STARTED RECEIVED: ", payload)

	if root == null:
		return

	if root.is_host():
		return

	_play_client_attack_visual(payload)


func receive_attack_hit(payload: Dictionary) -> void:
	if print_debug:
		print("ATTACK HIT RECEIVED: ", payload)

	if root == null:
		return

	if root.is_host():
		return

	_play_client_hit_visual(payload)


func receive_attack_finished(payload: Dictionary) -> void:
	if print_debug:
		print("ATTACK FINISHED RECEIVED: ", payload)


func receive_attack_sequence_finished(payload: Dictionary) -> void:
	if print_debug:
		print("ATTACK SEQUENCE FINISHED RECEIVED: ", payload)

func _play_client_attack_visual(payload: Dictionary) -> void:
	if root.slots_root == null:
		return

	var attacker_id: String = payload.get("attacker_card_runtime_id", "")
	var attacker_owner: SlotRow.SlotOwner = int(payload.get("attacker_owner", -1)) as SlotRow.SlotOwner
	var attacker_slot_index: int = int(payload.get("attacker_slot_index", -1))
	var target_owner: SlotRow.SlotOwner = int(payload.get("target_owner", -1)) as SlotRow.SlotOwner
	var target_slot_index: int = int(payload.get("target_slot_index", -1))
	var attack_event: String = payload.get("attack_event", "FORWARD")

	var attacker_card := root.slots_root.find_card_by_runtime_id(attacker_id)

	if attacker_card == null:
		print("CLIENT ATTACK VISUAL FAILED: attacker missing")
		return

	if attacker_card.attack == null:
		print("CLIENT ATTACK VISUAL FAILED: attack missing")
		return

	if attacker_card.attack.animation_runner == null:
		print("CLIENT ATTACK VISUAL FAILED: animation_runner missing")
		return

	var visual_attacker_owner := _get_visual_owner_for_local_client(attacker_owner)
	var visual_target_owner := _get_visual_owner_for_local_client(target_owner)

	var visual_attacker_slot_index := attacker_slot_index
	var visual_target_slot_index := target_slot_index

	if not root.is_host() and attack_event != "FORWARD":
		visual_attacker_slot_index = _get_visual_slot_index_for_local_client(attacker_slot_index)
		visual_target_slot_index = _get_visual_slot_index_for_local_client(target_slot_index)

	var attacker_slot := root.slots_root.get_slot(
		visual_attacker_owner,
		visual_attacker_slot_index
	)

	var target_slot := root.slots_root.get_slot(
		visual_target_owner,
		visual_target_slot_index
	)

	if attacker_slot == null:
		print("CLIENT ATTACK VISUAL FAILED: attacker slot missing")
		return

	if target_slot == null:
		print("CLIENT ATTACK VISUAL FAILED: target slot missing")
		return

	await attacker_card.attack.animation_runner.play_network_attack_step(
		attacker_slot,
		target_slot,
		visual_attacker_owner,
		root.slots_root.attack_animation_layer
	)

func _get_visual_owner_for_local_client(owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if root == null:
		return owner

	if root.is_host():
		return owner

	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER

func _play_client_hit_visual(payload: Dictionary) -> void:
	if root == null:
		return

	if root.slots_root == null:
		return

	var target_id: String = payload.get("target_card_runtime_id", "")

	if target_id.strip_edges() == "":
		var target_owner: SlotRow.SlotOwner = int(payload.get("target_owner", -1)) as SlotRow.SlotOwner
		var target_slot_index: int = int(payload.get("target_slot_index", -1))
		
		var visual_target_owner := _get_visual_owner_for_local_client(target_owner)
		var visual_slot_index := _get_visual_slot_index_for_local_client(target_slot_index)

		var target_slot := root.slots_root.get_slot(
			visual_target_owner,
			visual_slot_index
		)

		if target_slot != null:
			await root.slots_root.show_direct_damage_feedback(target_slot)

		return

	var target_card := root.slots_root.find_card_by_runtime_id(target_id)

	if target_card == null:
		print("CLIENT HIT VISUAL FAILED: target card missing")
		return

	if target_card.hurt == null:
		print("CLIENT HIT VISUAL FAILED: target hurt missing")
		return

	await target_card.hurt.play_network_hurt_feedback()

func _get_visual_slot_index_for_local_client(slot_index: int) -> int:
	if root == null:
		return slot_index

	if root.is_host():
		return slot_index

	return 5 - slot_index

func _connect_board_death_signals() -> void:
	connected_death_handlers.clear()

	if root == null:
		return

	if root.slots_root == null:
		return

	for slot in root.slots_root.get_all_slots():
		if slot == null:
			continue

		var card := slot.current_card

		if card == null:
			continue

		if card.die == null:
			continue

		if not card.die.die_started.is_connected(_on_card_die_started):
			card.die.die_started.connect(_on_card_die_started)

		connected_death_handlers.append(card.die)


func _disconnect_board_death_signals() -> void:
	for die_handler in connected_death_handlers:
		if die_handler == null:
			continue

		if not is_instance_valid(die_handler):
			continue

		if die_handler.die_started.is_connected(_on_card_die_started):
			die_handler.die_started.disconnect(_on_card_die_started)

	connected_death_handlers.clear()


func _on_card_die_started(card: CardRoot) -> void:
	var payload := _build_death_payload(card)

	if payload.is_empty():
		return

	_broadcast_card_died(payload)


func _build_death_payload(card: CardRoot) -> Dictionary:
	if card == null:
		return {}

	if not is_instance_valid(card):
		return {}

	if root == null:
		return {}

	if root.slots_root == null:
		return {}

	var slot := card.get_current_slot()

	if slot == null:
		return {}

	var owner := root.slots_root.get_owner_of_slot(slot)

	return {
		"card_runtime_id": card.get_runtime_id(),
		"owner": int(owner),
		"slot_index": slot.slot_index,
		"is_revenant": card.is_revenant()
	}


func _broadcast_card_died(payload: Dictionary) -> void:
	GDSync.call_func_all(root._receive_card_died, payload)


func receive_card_died(payload: Dictionary) -> void:
	if print_debug:
		print("CARD DIED RECEIVED: ", payload)

	if root == null:
		return

	if root.is_host():
		return

	_play_client_death_visual(payload)


func _play_client_death_visual(payload: Dictionary) -> void:
	if root.slots_root == null:
		return

	var runtime_id: String = payload.get("card_runtime_id", "")
	var owner: SlotRow.SlotOwner = int(payload.get("owner", SlotRow.SlotOwner.PLAYER)) as SlotRow.SlotOwner
	var is_revenant: bool = bool(payload.get("is_revenant", false))

	var card := root.slots_root.find_card_by_runtime_id(runtime_id)

	if card == null:
		print("CLIENT DEATH VISUAL FAILED: card missing")
		return

	if card.die == null:
		print("CLIENT DEATH VISUAL FAILED: die missing")
		return

	await card.die.play_network_die_visual(is_revenant, owner)

func _broadcast_all_board_card_stats() -> void:
	if root == null:
		return

	if root.slots_root == null:
		return

	for slot in root.slots_root.get_all_slots():
		if slot == null:
			continue

		var card := slot.current_card

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		var payload := _build_card_stats_payload(card)

		if payload.is_empty():
			continue

		GDSync.call_func_all(root._receive_card_stats_snapshot, payload)


func _build_card_stats_payload(card: CardRoot) -> Dictionary:
	if card == null:
		return {}

	if not is_instance_valid(card):
		return {}

	if card.stats == null:
		return {}

	return {
		"card_runtime_id": card.get_runtime_id(),
		"attack": card.stats.get_attack(),
		"health": card.stats.get_health(),
		"max_health": card.stats.get_max_health(),
		"cost": card.stats.get_cost(),
		"worth": card.stats.get_worth()
	}


func receive_card_stats_snapshot(payload: Dictionary) -> void:
	if root == null:
		return

	if root.is_host():
		return

	if root.slots_root == null:
		return

	var runtime_id: String = payload.get("card_runtime_id", "")
	var card := root.slots_root.find_card_by_runtime_id(runtime_id)

	if card == null:
		return

	if card.stats == null:
		return

	card.stats.apply_network_values(
		int(payload.get("attack", 0)),
		int(payload.get("health", 0)),
		int(payload.get("cost", 0)),
		int(payload.get("worth", 0)),
		int(payload.get("max_health", 0))
	)
