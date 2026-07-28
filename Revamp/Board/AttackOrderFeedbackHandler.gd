extends Node
class_name AttackOrderFeedbackHandler


@export_group("Systems")
@export var slots_root: SlotsRoot
@export var turn_order_state: MatchTurnOrderState
@export var match_network_root: MatchNetworkRoot

@export_group("Player Row Labels")
@export var player_order_labels: Array[Label] = []

@export_group("Opponent Row Labels")
@export var opponent_order_labels: Array[Label] = []

@export_group("Client Board Mapping")
@export var swap_rows_for_client: bool = true
@export var mirror_slot_indices_for_client: bool = true
@export var slots_per_row: int = 4

@export_group("Settings")
@export var use_ordinal_suffix: bool = true
@export var print_debug: bool = false


var last_board_signature: String = ""


func _ready() -> void:
	_hide_all_labels()

	if turn_order_state != null:
		if not turn_order_state.attacking_first_owner_changed.is_connected(
			_on_attacking_first_owner_changed
		):
			turn_order_state.attacking_first_owner_changed.connect(
				_on_attacking_first_owner_changed
			)

	call_deferred("refresh_now")


func _process(_delta: float) -> void:
	var current_signature := _build_board_signature()

	if current_signature == last_board_signature:
		return

	last_board_signature = current_signature
	_refresh_order_labels()


func refresh_now() -> void:
	last_board_signature = _build_board_signature()
	_refresh_order_labels()


func _refresh_order_labels() -> void:
	_hide_all_labels()

	if slots_root == null:
		return

	if slots_root.attack_order_handler == null:
		return

	var first_owner := _get_attacking_first_owner()
	var second_owner := _get_opposing_owner(first_owner)

	var entries := _build_feedback_entries(
		first_owner,
		second_owner
	)

	_sort_feedback_entries(entries)

	var order_number: int = 1

	for entry: Dictionary in entries:
		var visual_owner: SlotRow.SlotOwner = (
			entry["visual_owner"]
		)

		var visual_slot_index: int = int(
			entry["visual_slot_index"]
		)

		var order_label := _get_label_for_visual_slot(
			visual_owner,
			visual_slot_index
		)

		if order_label == null:
			continue

		order_label.text = _format_order_number(
			order_number
		)

		order_label.visible = true

		if print_debug:
			var canonical_owner: SlotRow.SlotOwner = (
				entry["canonical_owner"]
			)

			print(
				"ATTACK ORDER LABEL | ORDER=",
				order_number,
				" | CANONICAL OWNER=",
				_get_owner_name(canonical_owner),
				" | CANONICAL SLOT=",
				entry["canonical_slot_index"],
				" | VISUAL OWNER=",
				_get_owner_name(visual_owner),
				" | VISUAL SLOT=",
				visual_slot_index,
				" | PRIORITY=",
				entry["priority"]
			)

		order_number += 1


func _build_feedback_entries(
	first_owner: SlotRow.SlotOwner,
	second_owner: SlotRow.SlotOwner
) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []

	_append_owner_entries(
		entries,
		first_owner,
		0
	)

	_append_owner_entries(
		entries,
		second_owner,
		1
	)

	return entries


func _append_owner_entries(
	entries: Array[Dictionary],
	canonical_owner: SlotRow.SlotOwner,
	owner_order: int
) -> void:
	if slots_root == null:
		return

	var visual_owner := _get_visual_owner(
		canonical_owner
	)

	for slot: Slot in slots_root.get_slots_for_owner(
		visual_owner
	):
		if slot == null:
			continue

		var card := slot.current_card

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		var priority := _get_card_attack_priority(card)

		var canonical_slot_index := (
			_get_canonical_slot_index(
				slot.slot_index
			)
		)

		entries.append({
			"card": card,
			"canonical_owner": canonical_owner,
			"visual_owner": visual_owner,
			"canonical_slot_index": canonical_slot_index,
			"visual_slot_index": slot.slot_index,
			"owner_order": owner_order,
			"priority": priority
		})


func _sort_feedback_entries(
	entries: Array[Dictionary]
) -> void:
	entries.sort_custom(
		func(
			a: Dictionary,
			b: Dictionary
		) -> bool:
			var a_priority: int = int(
				a["priority"]
			)

			var b_priority: int = int(
				b["priority"]
			)

			if a_priority != b_priority:
				return a_priority > b_priority

			var a_owner_order: int = int(
				a["owner_order"]
			)

			var b_owner_order: int = int(
				b["owner_order"]
			)

			if a_owner_order != b_owner_order:
				return a_owner_order < b_owner_order

			var a_owner: SlotRow.SlotOwner = (
				a["canonical_owner"]
			)

			var a_slot_index: int = int(
				a["canonical_slot_index"]
			)

			var b_slot_index: int = int(
				b["canonical_slot_index"]
			)

			if _get_left_to_right(a_owner):
				return a_slot_index < b_slot_index

			return a_slot_index > b_slot_index
	)


func _get_card_attack_priority(
	card: CardRoot
) -> int:
	if card == null:
		return 0

	if not is_instance_valid(card):
		return 0

	if card.mutations == null:
		return 0

	return card.mutations.get_attack_priority()


func _get_attacking_first_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.attacking_first_owner


func _get_left_to_right(
	canonical_owner: SlotRow.SlotOwner
) -> bool:
	if slots_root == null:
		return true

	if slots_root.attack_order_handler == null:
		return true

	return (
		slots_root
		.attack_order_handler
		.get_left_to_right(canonical_owner)
	)


func _get_visual_owner(
	canonical_owner: SlotRow.SlotOwner
) -> SlotRow.SlotOwner:
	if not _is_client():
		return canonical_owner

	if not swap_rows_for_client:
		return canonical_owner

	return _get_opposing_owner(canonical_owner)


func _get_canonical_slot_index(
	visual_slot_index: int
) -> int:
	if not _is_client():
		return visual_slot_index

	if not mirror_slot_indices_for_client:
		return visual_slot_index

	return (
		slots_per_row
		+ 1
		- visual_slot_index
	)


func _get_label_for_visual_slot(
	visual_owner: SlotRow.SlotOwner,
	visual_slot_index: int
) -> Label:
	var label_index := visual_slot_index - 1

	if label_index < 0:
		return null

	if visual_owner == SlotRow.SlotOwner.PLAYER:
		if label_index >= player_order_labels.size():
			return null

		return player_order_labels[label_index]

	if label_index >= opponent_order_labels.size():
		return null

	return opponent_order_labels[label_index]


func _hide_all_labels() -> void:
	for order_label: Label in player_order_labels:
		if order_label == null:
			continue

		order_label.visible = false

	for order_label: Label in opponent_order_labels:
		if order_label == null:
			continue

		order_label.visible = false


func _build_board_signature() -> String:
	if slots_root == null:
		return "slots_root_missing"

	var pieces := PackedStringArray()

	pieces.append(
		"first_owner=%s"
		% int(_get_attacking_first_owner())
	)

	pieces.append(
		"is_client=%s"
		% str(_is_client())
	)

	pieces.append(
		"swap_rows=%s"
		% str(swap_rows_for_client)
	)

	pieces.append(
		"mirror_slots=%s"
		% str(mirror_slot_indices_for_client)
	)

	if slots_root.attack_order_handler != null:
		pieces.append(
			"player_direction=%s"
			% str(
				slots_root
				.attack_order_handler
				.player_left_to_right
			)
		)

		pieces.append(
			"opponent_direction=%s"
			% str(
				slots_root
				.attack_order_handler
				.opponent_left_to_right
			)
		)

	for visual_owner in [
		SlotRow.SlotOwner.PLAYER,
		SlotRow.SlotOwner.OPPONENT
	]:
		for slot: Slot in slots_root.get_slots_for_owner(
			visual_owner
		):
			if slot == null:
				continue

			var runtime_id := "empty"
			var priority: int = 0

			var card := slot.current_card

			if card != null and is_instance_valid(card):
				runtime_id = card.get_runtime_id()
				priority = _get_card_attack_priority(card)

			pieces.append(
				"%s:%s:%s:%s" % [
					int(visual_owner),
					slot.slot_index,
					runtime_id,
					priority
				]
			)

	return "|".join(pieces)


func _is_client() -> bool:
	if match_network_root == null:
		return false

	return not match_network_root.is_host()


func _get_opposing_owner(
	owner: SlotRow.SlotOwner
) -> SlotRow.SlotOwner:
	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER


func _format_order_number(value: int) -> String:
	if not use_ordinal_suffix:
		return str(value)

	var last_two_digits := value % 100

	if last_two_digits >= 11 and last_two_digits <= 13:
		return "%dth" % value

	match value % 10:
		1:
			return "%dst" % value

		2:
			return "%dnd" % value

		3:
			return "%drd" % value

		_:
			return "%dth" % value


func _get_owner_name(
	owner: SlotRow.SlotOwner
) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "PLAYER"

	return "OPPONENT"


func _on_attacking_first_owner_changed(
	_owner: SlotRow.SlotOwner
) -> void:
	refresh_now()
