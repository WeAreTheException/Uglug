extends Node
class_name SacrificeController

signal sacrifice_requirement_changed(current_worth: int, required_worth: int)
signal sacrifice_requirement_met(current_worth: int, required_worth: int)
signal sacrifice_requirement_unmet(current_worth: int, required_worth: int)

signal pending_sacrifice_started(primed_card: CardRoot, cards: Array[CardRoot])
signal pending_sacrifice_undone(primed_card: CardRoot, cards: Array[CardRoot])
signal sacrifice_committed(cards: Array[CardRoot])
signal sacrifice_blocked(reason: String)

@export var player_hand: PlayerHandRoot

@export var requirement: SacrificeRequirement
@export var pending_boat: PendingSacrificeBoat
@export var committer: SacrificeCommitter

@export var auto_sacrifice_when_cost_met: bool = false
@export var enable_undo_key: bool = true

var is_processing: bool = false
var is_committing: bool = false


func _ready() -> void:
	_connect_hand()
	_update_requirement_state()


func _input(event: InputEvent) -> void:
	if not enable_undo_key:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Z and (event.ctrl_pressed or event.meta_pressed):
			undo_pending_sacrifice()


func request_sacrifice() -> void:
	if is_processing:
		return

	if pending_boat != null and pending_boat.has_pending():
		return

	var primed_card := _get_primed_card()
	var selected_cards := _get_selected_cards()

	if primed_card == null:
		sacrifice_blocked.emit("No primed card.")
		return

	if requirement == null:
		sacrifice_blocked.emit("Missing SacrificeRequirement.")
		return

	if not requirement.is_requirement_met(primed_card, selected_cards):
		sacrifice_blocked.emit("Sacrifice cost not met.")
		return

	_begin_pending_sacrifice(primed_card, selected_cards)


func undo_pending_sacrifice() -> void:
	if is_committing:
		return

	if pending_boat == null:
		return

	if not pending_boat.has_pending():
		return

	var old_primed := pending_boat.get_pending_primed_card()
	var entries := pending_boat.undo_pending()

	var restored_cards: Array[CardRoot] = []

	for entry in entries:
		var card := entry["card"] as CardRoot

		if card == null:
			continue

		card.visible = true
		card.reset_sacrifice_feedback()
		card.clear_hand_feedback()
		restored_cards.append(card)

	pending_sacrifice_undone.emit(old_primed, restored_cards)
	_update_requirement_state()


func commit_pending_sacrifice() -> void:
	if pending_boat == null:
		return

	if not pending_boat.has_pending():
		return

	if committer == null:
		sacrifice_blocked.emit("Missing SacrificeCommitter.")
		return

	is_committing = true

	var cards := pending_boat.take_pending_cards()

	for card: CardRoot in cards:
		if card == null:
			continue

		if player_hand != null:
			player_hand.remove_card_from_hand(card)

	committer.commit_cards(cards)

	is_committing = false

	sacrifice_committed.emit(cards)
	_update_requirement_state()


func set_auto_sacrifice_enabled(value: bool) -> void:
	auto_sacrifice_when_cost_met = value
	_try_auto_sacrifice()


func _begin_pending_sacrifice(
	primed_card: CardRoot,
	selected_cards: Array[CardRoot]
) -> void:
	if pending_boat == null:
		sacrifice_blocked.emit("Missing PendingSacrificeBoat.")
		return

	is_processing = true

	var entries: Array[Dictionary] = []

	for card in selected_cards:
		if card == null:
			continue

		if card == primed_card:
			continue

		var index := -1

		if player_hand != null:
			index = player_hand.get_index_of_card(card)

		if index < 0:
			continue

		entries.append({
			"card": card,
			"index": index
		})

	if player_hand != null:
		player_hand.clear_sacrifice_selection()

	var pending_cards := pending_boat.begin_pending(primed_card, entries)

	is_processing = false

	pending_sacrifice_started.emit(primed_card, pending_cards)
	_update_requirement_state()


func _connect_hand() -> void:
	if player_hand == null:
		return

	if not player_hand.sacrifice_requested.is_connected(_on_sacrifice_requested):
		player_hand.sacrifice_requested.connect(_on_sacrifice_requested)

	if not player_hand.card_unprimed.is_connected(_on_card_unprimed):
		player_hand.card_unprimed.connect(_on_card_unprimed)

	if not player_hand.sacrifice_selection_changed.is_connected(_on_selection_changed):
		player_hand.sacrifice_selection_changed.connect(_on_selection_changed)


func _on_sacrifice_requested(
	_primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	request_sacrifice()


func _on_selection_changed(_cards: Array[CardRoot]) -> void:
	_update_requirement_state()
	_try_auto_sacrifice()


func _on_card_unprimed(_card: CardRoot) -> void:
	if is_committing:
		return

	undo_pending_sacrifice()

	if player_hand != null:
		player_hand.clear_sacrifice_selection()

	_update_requirement_state()


func _try_auto_sacrifice() -> void:
	if auto_sacrifice_when_cost_met:
		request_sacrifice()


func _update_requirement_state() -> void:
	var primed_card := _get_primed_card()
	var cards := _get_selected_cards()

	var current := 0
	var required := 0

	if requirement != null:
		current = requirement.get_current_worth(cards)
		required = requirement.get_required_worth(primed_card)

	sacrifice_requirement_changed.emit(current, required)

	if primed_card != null and current >= required:
		sacrifice_requirement_met.emit(current, required)
	else:
		sacrifice_requirement_unmet.emit(current, required)


func _get_primed_card() -> CardRoot:
	if player_hand == null:
		return null

	return player_hand.get_primed_card()


func _get_selected_cards() -> Array[CardRoot]:
	if player_hand == null:
		return []

	return player_hand.get_selected_sacrifice_cards()
