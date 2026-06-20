extends RefCounted
class_name MatchSnapshotComparer


func compare(host_snapshot: Dictionary, local_snapshot: Dictionary) -> bool:
	var has_mismatch := false

	has_mismatch = _compare_value(host_snapshot, local_snapshot, "match_state") or has_mismatch
	has_mismatch = _compare_value(host_snapshot, local_snapshot, "round") or has_mismatch
	has_mismatch = _compare_value(host_snapshot, local_snapshot, "score") or has_mismatch
	has_mismatch = _compare_draw_piles(host_snapshot, local_snapshot) or has_mismatch
	has_mismatch = _compare_board_runtime_ids(host_snapshot, local_snapshot) or has_mismatch

	if not has_mismatch:
		print("SNAPSHOT COMPARE: no mismatches")

	return not has_mismatch


func _compare_value(host: Dictionary, local: Dictionary, key: String) -> bool:
	var host_value = host.get(key, null)
	var local_value = local.get(key, null)

	if host_value == local_value:
		return false

	print(
		"SNAPSHOT MISMATCH: ",
		key,
		" | host=",
		host_value,
		" local=",
		local_value
	)

	return true


func _compare_draw_piles(host: Dictionary, local: Dictionary) -> bool:
	var has_mismatch := false

	var host_piles: Dictionary = host.get("draw_piles", {})
	var local_piles: Dictionary = local.get("draw_piles", {})

	for key in ["player", "opponent"]:
		var host_count := int(host_piles.get(key, {}).get("count", -1))
		var local_count := int(local_piles.get(key, {}).get("count", -1))

		if host_count != local_count:
			print(
				"SNAPSHOT MISMATCH: draw_piles.",
				key,
				".count | host=",
				host_count,
				" local=",
				local_count
			)
			has_mismatch = true

	return has_mismatch


func _compare_board_runtime_ids(host: Dictionary, local: Dictionary) -> bool:
	var has_mismatch := false

	var host_slots := _build_board_lookup(host.get("board", []))
	var local_slots := _build_board_lookup(local.get("board", []))

	var all_keys: Array[String] = []

	for key in host_slots.keys():
		if not all_keys.has(key):
			all_keys.append(key)

	for key in local_slots.keys():
		if not all_keys.has(key):
			all_keys.append(key)

	all_keys.sort()

	for key in all_keys:
		var host_runtime := _get_slot_runtime_id(host_slots.get(key, {}))
		var local_runtime := _get_slot_runtime_id(local_slots.get(key, {}))

		if host_runtime != local_runtime:
			print(
				"SNAPSHOT MISMATCH: board.",
				key,
				" runtime_id | host=",
				host_runtime,
				" local=",
				local_runtime
			)
			has_mismatch = true

	return has_mismatch


func _build_board_lookup(board: Array) -> Dictionary:
	var result := {}

	for slot_payload in board:
		if not slot_payload is Dictionary:
			continue

		var owner := int(slot_payload.get("owner", -1))
		var slot_index := int(slot_payload.get("slot_index", -1))
		var key := str(owner) + ":" + str(slot_index)

		result[key] = slot_payload

	return result


func _get_slot_runtime_id(slot_payload: Dictionary) -> String:
	var card = slot_payload.get("card", null)

	if card == null:
		return "null"

	if not card is Dictionary:
		return "null"

	return str(card.get("runtime_id", ""))
