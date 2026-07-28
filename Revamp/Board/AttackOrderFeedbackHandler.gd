extends Node
class_name AttackOrderFeedbackHandler


@export_group("Systems")
@export var slots_root: SlotsRoot
@export var turn_order_state: MatchTurnOrderState
@export var match_network_root: MatchNetworkRoot

@export_group("Player Labels")
@export var player_order_labels: Array[Label] = []

@export_group("Opponent Labels")
@export var opponent_order_labels: Array[Label] = []

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

	var first_owner := _get_visual_attacking_first_owner()
	var second_owner := _get_opposing_owner(first_owner)

	var entries := (
		slots_root
		.attack_order_handler
		.get_global_attack_entries_in_order(
			first_owner,
			second_owner
		)
	)

	var order_number: int = 1

	for entry: Dictionary in entries:
		var card := (
			slots_root
			.attack_order_handler
			.get_valid_card_from_global_entry(entry)
		)

		if card == null:
			continue

		if not entry.has("slot"):
			continue

		var slot := entry["slot"] as Slot

		if slot == null:
			continue

		if not is_instance_valid(slot):
			continue

		var current_order_number := order_number
		order_number += 1

		var slot_owner := slots_root.get_owner_of_slot(slot)

		var order_label := _get_label_for_slot(
			slot_owner,
			slot.slot_index
		)

		if order_label == null:
			continue

		order_label.text = _format_order_number(
			current_order_number
		)

		order_label.visible = true

	if print_debug:
		print(
			"ATTACK ORDER FEEDBACK REFRESHED | ",
			"VISIBLE ENTRIES: ",
			order_number - 1
		)


func _build_board_signature() -> String:
	if slots_root == null:
		return "slots_root_missing"

	var pieces := PackedStringArray()

	var first_owner := _get_visual_attacking_first_owner()

	pieces.append(
		"first_owner=%s" % int(first_owner)
	)

	if slots_root.attack_order_handler != null:
		pieces.append(
			"player_direction=%s"
			% slots_root.attack_order_handler.player_left_to_right
		)

		pieces.append(
			"opponent_direction=%s"
			% slots_root.attack_order_handler.opponent_left_to_right
		)

	for owner in [
		SlotRow.SlotOwner.PLAYER,
		SlotRow.SlotOwner.OPPONENT
	]:
		for slot: Slot in slots_root.get_slots_for_owner(owner):
			if slot == null:
				continue

			var runtime_id := "empty"
			var priority: int = 0

			var card := slot.current_card

			if card != null and is_instance_valid(card):
				runtime_id = card.get_runtime_id()

				if card.mutations != null:
					priority = (
						card
						.mutations
						.get_attack_priority()
					)

			pieces.append(
				"%s:%s:%s:%s" % [
					int(owner),
					slot.slot_index,
					runtime_id,
					priority
				]
			)

	return "|".join(pieces)


func _get_label_for_slot(
	owner: SlotRow.SlotOwner,
	slot_index: int
) -> Label:
	var label_index := slot_index - 1

	if label_index < 0:
		return null

	if owner == SlotRow.SlotOwner.PLAYER:
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


func _get_visual_attacking_first_owner() -> SlotRow.SlotOwner:
	var owner := SlotRow.SlotOwner.PLAYER

	if turn_order_state != null:
		owner = turn_order_state.attacking_first_owner

	if match_network_root == null:
		return owner

	if match_network_root.is_host():
		return owner

	return _get_opposing_owner(owner)


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


func _on_attacking_first_owner_changed(
	_owner: SlotRow.SlotOwner
) -> void:
	refresh_now()
