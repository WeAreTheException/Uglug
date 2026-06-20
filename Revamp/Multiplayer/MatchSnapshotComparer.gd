extends RefCounted
class_name MatchSnapshotComparer


func compare(host_snapshot: Dictionary, local_snapshot: Dictionary) -> bool:
	var has_mismatch := false

	has_mismatch = _compare_value(host_snapshot, local_snapshot, "match_state") or has_mismatch
	has_mismatch = _compare_value(host_snapshot, local_snapshot, "round") or has_mismatch
	has_mismatch = _compare_value(host_snapshot, local_snapshot, "active_owner") or has_mismatch
	has_mismatch = _compare_value(host_snapshot, local_snapshot, "score") or has_mismatch
	has_mismatch = _compare_hand_counts(host_snapshot, local_snapshot) or has_mismatch
	has_mismatch = _compare_hand_runtime_ids(host_snapshot, local_snapshot) or has_mismatch
	has_mismatch = _compare_draw_piles(host_snapshot, local_snapshot) or has_mismatch
	has_mismatch = _compare_board_runtime_ids(host_snapshot, local_snapshot) or has_mismatch
	has_mismatch = _compare_board_card_details(host_snapshot, local_snapshot) or has_mismatch
	has_mismatch = _compare_hand_card_details(host_snapshot, local_snapshot) or has_mismatch

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

func _compare_board_card_details(host: Dictionary, local: Dictionary) -> bool:
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
		var host_card: Variant = _get_slot_card(host_slots.get(key, {}))
		var local_card: Variant = _get_slot_card(local_slots.get(key, {}))

		has_mismatch = _compare_card_detail(
			"board." + key,
			host_card,
			local_card
		) or has_mismatch

	return has_mismatch


func _compare_hand_card_details(host: Dictionary, local: Dictionary) -> bool:
	var has_mismatch := false

	var host_hands: Dictionary = host.get("hands", {})
	var local_hands: Dictionary = local.get("hands", {})

	for key in ["player", "opponent"]:
		var host_cards := _build_card_lookup_by_runtime_id(
			host_hands.get(key, {}).get("cards", [])
		)
		var local_cards := _build_card_lookup_by_runtime_id(
			local_hands.get(key, {}).get("cards", [])
		)

		var all_ids: Array[String] = []

		for runtime_id in host_cards.keys():
			if not all_ids.has(runtime_id):
				all_ids.append(runtime_id)

		for runtime_id in local_cards.keys():
			if not all_ids.has(runtime_id):
				all_ids.append(runtime_id)

		all_ids.sort()

		for runtime_id in all_ids:
			has_mismatch = _compare_card_detail(
				"hands." + key + "." + runtime_id,
				host_cards.get(runtime_id, {}),
				local_cards.get(runtime_id, {})
			) or has_mismatch

	return has_mismatch


func _compare_card_detail(
	label: String,
	host_card,
	local_card
) -> bool:
	var has_mismatch := false

	if host_card == null and local_card == null:
		return false

	if host_card == null or local_card == null:
		print(
			"SNAPSHOT MISMATCH: ",
			label,
			" presence | host=",
			host_card,
			" local=",
			local_card
		)
		return true

	if not host_card is Dictionary or not local_card is Dictionary:
		return false

	has_mismatch = _compare_card_field(label, host_card, local_card, "card_id") or has_mismatch
	has_mismatch = _compare_card_field(label, host_card, local_card, "runtime_id") or has_mismatch
	has_mismatch = _compare_card_field(label, host_card, local_card, "stats") or has_mismatch
	has_mismatch = _compare_card_mutations(label, host_card, local_card) or has_mismatch

	return has_mismatch


func _compare_card_field(
	label: String,
	host_card: Dictionary,
	local_card: Dictionary,
	field: String
) -> bool:
	var host_value = host_card.get(field, null)
	var local_value = local_card.get(field, null)

	if host_value == local_value:
		return false

	print(
		"SNAPSHOT MISMATCH: ",
		label,
		".",
		field,
		" | host=",
		host_value,
		" local=",
		local_value
	)

	return true


func _compare_card_mutations(
	label: String,
	host_card: Dictionary,
	local_card: Dictionary
) -> bool:
	var host_mutations: Array = host_card.get("mutations", [])
	var local_mutations: Array = local_card.get("mutations", [])

	host_mutations.sort()
	local_mutations.sort()

	if host_mutations == local_mutations:
		return false

	print(
		"SNAPSHOT MISMATCH: ",
		label,
		".mutations | host=",
		host_mutations,
		" local=",
		local_mutations
	)

	return true


func _get_slot_card(slot_payload: Dictionary) -> Variant:
	var card = slot_payload.get("card", null)

	if card == null:
		return null

	if not card is Dictionary:
		return null

	return card


func _build_card_lookup_by_runtime_id(cards: Array) -> Dictionary:
	var result := {}

	for card_payload in cards:
		if not card_payload is Dictionary:
			continue

		var runtime_id := str(card_payload.get("runtime_id", ""))

		if runtime_id == "":
			continue

		result[runtime_id] = card_payload

	return result

func _compare_hand_counts(host: Dictionary, local: Dictionary) -> bool:
	var has_mismatch := false

	var host_hands: Dictionary = host.get("hands", {})
	var local_hands: Dictionary = local.get("hands", {})

	for key in ["player", "opponent"]:
		var host_count := int(host_hands.get(key, {}).get("count", -1))
		var local_count := int(local_hands.get(key, {}).get("count", -1))

		if host_count != local_count:
			print(
				"SNAPSHOT MISMATCH: hands.",
				key,
				".count | host=",
				host_count,
				" local=",
				local_count
			)
			has_mismatch = true

	return has_mismatch

func _compare_hand_runtime_ids(host: Dictionary, local: Dictionary) -> bool:
	var has_mismatch := false

	var host_hands: Dictionary = host.get("hands", {})
	var local_hands: Dictionary = local.get("hands", {})

	for key in ["player", "opponent"]:
		var host_ids := _get_hand_runtime_ids(host_hands.get(key, {}))
		var local_ids := _get_hand_runtime_ids(local_hands.get(key, {}))

		if host_ids != local_ids:
			print(
				"SNAPSHOT MISMATCH: hands.",
				key,
				".runtime_ids | host=",
				host_ids,
				" local=",
				local_ids
			)
			has_mismatch = true

	return has_mismatch


func _get_hand_runtime_ids(hand_payload: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	var cards: Array = hand_payload.get("cards", [])

	for card_payload in cards:
		if not card_payload is Dictionary:
			continue

		ids.append(str(card_payload.get("runtime_id", "")))

	return ids
