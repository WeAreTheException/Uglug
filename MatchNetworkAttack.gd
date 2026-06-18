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
