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
