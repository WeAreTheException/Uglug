extends RefCounted
class_name MatchSnapshotResync


func preview_resync(root: MatchNetworkRoot, host_snapshot: Dictionary) -> void:
	if root == null:
		return

	print("=== RESYNC PREVIEW ===")

	_preview_hands(root, host_snapshot)
	_preview_board(root, host_snapshot)
	_preview_score(root, host_snapshot)
	_preview_draw_piles(host_snapshot)

	print("=== END RESYNC PREVIEW ===")


func _preview_hands(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	var hands: Dictionary = snapshot.get("hands", {})

	_preview_hand(root, SlotRow.SlotOwner.PLAYER, "player", hands)
	_preview_hand(root, SlotRow.SlotOwner.OPPONENT, "opponent", hands)


func _preview_hand(
	root: MatchNetworkRoot,
	owner: SlotRow.SlotOwner,
	key: String,
	hands: Dictionary
) -> void:
	var current_count := 0

	if root.deck_system_root != null:
		var hand := root.deck_system_root.get_hand_for_owner(owner)
		if hand != null:
			current_count = hand.get_card_count()

	var hand_payload: Dictionary = hands.get(key, {})
	var cards: Array = hand_payload.get("cards", [])
	var ids: Array[String] = []

	for card_payload in cards:
		if not card_payload is Dictionary:
			continue

		ids.append(str(card_payload.get("runtime_id", "")))

	print(
		"Would clear ",
		key,
		" hand: ",
		current_count,
		" cards"
	)

	print(
		"Would rebuild ",
		key,
		" hand runtime IDs: ",
		ids
	)


func _preview_board(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	var current_slots := 0

	if root.slots_root != null:
		current_slots = root.slots_root.get_all_slots().size()

	var board: Array = snapshot.get("board", [])
	var ids: Array[String] = []

	for slot_payload in board:
		if not slot_payload is Dictionary:
			continue

		var card = slot_payload.get("card", null)

		if card == null:
			continue

		if not card is Dictionary:
			continue

		ids.append(
			str(slot_payload.get("owner", -1))
			+ ":"
			+ str(slot_payload.get("slot_index", -1))
			+ "="
			+ str(card.get("runtime_id", ""))
		)

	print("Would clear board: ", current_slots, " slots")
	print("Would rebuild board runtime IDs: ", ids)


func _preview_score(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	var current_score := 0

	if root.match_score_state != null:
		current_score = root.match_score_state.score

	print(
		"Would restore score: current=",
		current_score,
		" host=",
		int(snapshot.get("score", 0))
	)


func _preview_draw_piles(snapshot: Dictionary) -> void:
	print("Would restore draw pile counts: ", snapshot.get("draw_piles", {}))

func apply_resync(root: MatchNetworkRoot, host_snapshot: Dictionary) -> void:
	if root == null:
		return

	print("=== APPLYING DEBUG RESYNC ===")

	_restore_score(root, host_snapshot)
	_restore_draw_piles(root, host_snapshot)
	_restore_hands(root, host_snapshot)
	_restore_board(root, host_snapshot)

	print("=== DEBUG RESYNC DONE: score + draw piles + hands + board ===")


func _restore_score(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	if root.match_score_state == null:
		return

	var score := int(snapshot.get("score", 0))

	root.match_score_state.score = score
	root.match_score_state.score_changed.emit(score)

	print("RESYNC SCORE: ", score)


func _restore_draw_piles(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	if root.deck_system_root == null:
		return

	var draw_piles: Dictionary = snapshot.get("draw_piles", {})

	_restore_draw_pile(
		root,
		SlotRow.SlotOwner.PLAYER,
		draw_piles.get("player", {})
	)

	_restore_draw_pile(
		root,
		SlotRow.SlotOwner.OPPONENT,
		draw_piles.get("opponent", {})
	)


func _restore_draw_pile(
	root: MatchNetworkRoot,
	owner: SlotRow.SlotOwner,
	pile_payload: Dictionary
) -> void:
	var draw_pile := root.deck_system_root.get_draw_pile_for_owner(owner)

	if draw_pile == null:
		return

	var entries: Array = pile_payload.get("entries", [])

	if draw_pile.has_method("restore_entries"):
		draw_pile.restore_entries(entries)
	else:
		draw_pile.setup_with_entries(entries)

	print(
		"RESYNC DRAW PILE: owner=",
		int(owner),
		" count=",
		entries.size()
	)

func _restore_hands(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	if root.deck_system_root == null:
		return

	var hands: Dictionary = snapshot.get("hands", {})

	_restore_hand(
		root,
		SlotRow.SlotOwner.PLAYER,
		hands.get("player", {})
	)

	_restore_hand(
		root,
		SlotRow.SlotOwner.OPPONENT,
		hands.get("opponent", {})
	)


func _restore_hand(
	root: MatchNetworkRoot,
	owner: SlotRow.SlotOwner,
	hand_payload: Dictionary
) -> void:
	var hand := root.deck_system_root.get_hand_for_owner(owner)

	if hand == null:
		return

	hand.clear_cards(true)

	var cards: Array = hand_payload.get("cards", [])

	for card_payload in cards:
		if not card_payload is Dictionary:
			continue

		_spawn_hand_card_from_payload(root, hand, card_payload)

	hand.arrange_cards()
	hand.emit_prime_state()

	print(
		"RESYNC HAND: owner=",
		int(owner),
		" count=",
		cards.size()
	)


func _spawn_hand_card_from_payload(
	root: MatchNetworkRoot,
	hand: PlayerHandRoot,
	card_payload: Dictionary
) -> CardRoot:
	if root.deck_system_root == null:
		return null

	var card_id := str(card_payload.get("card_id", ""))
	var runtime_id := str(card_payload.get("runtime_id", ""))

	var card_data := root.deck_system_root.get_card_data(card_id)

	if card_data == null:
		print("RESYNC HAND CARD FAILED: missing card_data ", card_id)
		return null

	var card := hand.spawn_card_with_runtime_id(card_data, runtime_id)

	if card == null:
		print("RESYNC HAND CARD FAILED: spawn failed ", card_id)
		return null

	_apply_card_snapshot_details(root, card, card_payload)

	return card


func _apply_card_snapshot_details(
	root: MatchNetworkRoot,
	card: CardRoot,
	card_payload: Dictionary
) -> void:
	if card == null:
		return

	_apply_card_mutations(root, card, card_payload.get("mutations", []))


func _apply_card_mutations(
	root: MatchNetworkRoot,
	card: CardRoot,
	mutation_ids: Array
) -> void:
	if root.deck_system_root == null:
		return

	if card.mutations == null:
		return

	for mutation_id in mutation_ids:
		var clean_id := str(mutation_id).strip_edges()

		if clean_id == "":
			continue

		var mutation := root.deck_system_root._find_mutation_by_id(clean_id)

		if mutation == null:
			print("RESYNC MUTATION FAILED: ", clean_id)
			continue

		if not _card_has_mutation_id(card, clean_id):
			card.mutations.add_buff_mutation(mutation)

func _card_has_mutation_id(card: CardRoot, mutation_id: String) -> bool:
	if card == null:
		return false

	if card.mutations == null:
		return false

	if card.mutations.has_method("get_all_mutations"):
		for mutation in card.mutations.get_all_mutations():
			if mutation == null:
				continue

			if mutation.has_method("get_safe_mutation_id"):
				if mutation.get_safe_mutation_id() == mutation_id:
					return true

	return false

func _restore_board(root: MatchNetworkRoot, snapshot: Dictionary) -> void:
	if root.slots_root == null:
		return

	if root.deck_system_root == null:
		return

	_clear_board(root)

	var board: Array = snapshot.get("board", [])

	for slot_payload in board:
		if not slot_payload is Dictionary:
			continue

		_restore_board_slot(root, slot_payload)

	root.slots_root.refresh_board_mutations()

	print("RESYNC BOARD: slots=", board.size())


func _clear_board(root: MatchNetworkRoot) -> void:
	for slot: Slot in root.slots_root.get_all_slots():
		if slot == null:
			continue

		var card := slot.current_card

		if card != null and is_instance_valid(card):
			card.queue_free()

		slot.clear_card()


func _restore_board_slot(
	root: MatchNetworkRoot,
	slot_payload: Dictionary
) -> void:
	var card_payload = slot_payload.get("card", null)

	if card_payload == null:
		return

	if not card_payload is Dictionary:
		return

	var owner: SlotRow.SlotOwner = int(
		slot_payload.get("owner", SlotRow.SlotOwner.PLAYER)
	) as SlotRow.SlotOwner

	var slot_index := int(slot_payload.get("slot_index", -1))
	var slot := _get_local_slot_from_canonical(root, owner, slot_index)

	if slot == null:
		print(
			"RESYNC BOARD SLOT FAILED: missing slot owner=",
			int(owner),
			" index=",
			slot_index
		)
		return

	var card := _spawn_board_card_from_payload(root, card_payload)

	if card == null:
		return

	_add_card_to_board_layer(root, card, slot)
	card.setup_board_context(root.slots_root)

	if card.board_presence != null:
		card.board_presence.enter_slot(slot, card)
	else:
		slot.assign_card(card)

	card.global_position = slot.get_card_anchor_global_position()
	card.rotation_degrees = 0.0

	_apply_card_snapshot_details(root, card, card_payload)


func _get_local_slot_from_canonical(
	root: MatchNetworkRoot,
	canonical_owner: SlotRow.SlotOwner,
	canonical_slot_index: int
) -> Slot:
	if root == null:
		return null

	if root.slots_root == null:
		return null

	var local_owner := canonical_owner
	var local_slot_index := canonical_slot_index

	if not root.is_host():
		if canonical_owner == SlotRow.SlotOwner.PLAYER:
			local_owner = SlotRow.SlotOwner.OPPONENT
		else:
			local_owner = SlotRow.SlotOwner.PLAYER

		local_slot_index = _mirror_slot_index(
			root,
			local_owner,
			canonical_slot_index
		)

	return root.slots_root.get_slot(local_owner, local_slot_index)


func _mirror_slot_index(
	root: MatchNetworkRoot,
	local_owner: SlotRow.SlotOwner,
	canonical_slot_index: int
) -> int:
	var slots := root.slots_root.get_slots_for_owner(local_owner)
	var max_index := 0

	for slot: Slot in slots:
		if slot == null:
			continue

		max_index = max(max_index, slot.slot_index)

	if max_index <= 0:
		return canonical_slot_index

	return max_index + 1 - canonical_slot_index


func _spawn_board_card_from_payload(
	root: MatchNetworkRoot,
	card_payload: Dictionary
) -> CardRoot:
	if root.slots_root == null:
		return null

	if root.slots_root.card_scene == null:
		print("RESYNC BOARD CARD FAILED: card_scene missing")
		return null

	var card_id := str(card_payload.get("card_id", ""))
	var runtime_id := str(card_payload.get("runtime_id", ""))
	var card_data := root.deck_system_root.get_card_data(card_id)

	if card_data == null:
		print("RESYNC BOARD CARD FAILED: missing card_data ", card_id)
		return null

	var card := root.slots_root.card_scene.instantiate() as CardRoot

	if card == null:
		print("RESYNC BOARD CARD FAILED: card_scene root is not CardRoot")
		return null

	card.setup(card_data)
	card.set_runtime_id(runtime_id)
	card.setup_deck_system_context(root.deck_system_root)

	return card


func _add_card_to_board_layer(
	root: MatchNetworkRoot,
	card: CardRoot,
	slot: Slot
) -> void:
	var parent := root.slots_root.spawned_card_parent

	if parent == null:
		parent = slot

	parent.add_child(card)
