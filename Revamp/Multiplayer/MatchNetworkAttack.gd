extends Node
class_name MatchNetworkAttack

var root: MatchNetworkRoot = null


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

	print("CONFIRMED ATTACK EXECUTING: ", payload)

	_broadcast_attack_sequence_started(payload)

	await card.attack.perform_attack()

	_broadcast_attack_sequence_finished(payload)

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
	print("ATTACK SEQUENCE STARTED RECEIVED: ", payload)


func receive_attack_started(payload: Dictionary) -> void:
	print("ATTACK STARTED RECEIVED: ", payload)

	if root == null:
		return

	if root.is_host():
		return

	_play_client_attack_visual(payload)


func receive_attack_hit(payload: Dictionary) -> void:
	print("ATTACK HIT RECEIVED: ", payload)

	if root == null:
		return

	if root.is_host():
		return

	_play_client_hit_visual(payload)


func receive_attack_finished(payload: Dictionary) -> void:
	print("ATTACK FINISHED RECEIVED: ", payload)


func receive_attack_sequence_finished(payload: Dictionary) -> void:
	print("ATTACK SEQUENCE FINISHED RECEIVED: ", payload)

func _play_client_attack_visual(payload: Dictionary) -> void:
	if root.slots_root == null:
		return

	var attacker_id: String = payload.get("attacker_card_runtime_id", "")
	var attacker_owner: SlotRow.SlotOwner = int(payload.get("attacker_owner", -1)) as SlotRow.SlotOwner
	var attacker_slot_index: int = int(payload.get("attacker_slot_index", -1))
	var target_owner: SlotRow.SlotOwner = int(payload.get("target_owner", -1)) as SlotRow.SlotOwner
	var target_slot_index: int = int(payload.get("target_slot_index", -1))

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

	var attacker_slot := root.slots_root.get_slot(attacker_owner, attacker_slot_index)
	var target_slot := root.slots_root.get_slot(target_owner, target_slot_index)

	if attacker_slot == null:
		print("CLIENT ATTACK VISUAL FAILED: attacker slot missing")
		return

	if target_slot == null:
		print("CLIENT ATTACK VISUAL FAILED: target slot missing")
		return

	await attacker_card.attack.animation_runner.play_network_attack_step(
		attacker_slot,
		target_slot,
		_get_visual_owner_for_local_client(attacker_owner),
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
		var target_slot := root.slots_root.get_slot(target_owner, target_slot_index)

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
