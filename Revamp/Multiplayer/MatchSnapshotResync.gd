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

	print("=== DEBUG RESYNC DONE: score + draw piles only ===")


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
