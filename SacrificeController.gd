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
@export var sacrifice_selection_root: SacrificeSelectionRoot

@export var requirement: SacrificeRequirement
@export var pending_boat: PendingSacrificeBoat
@export var committer: SacrificeCommitter
@export var revenant_warning: SacrificeRevenantWarningLabel

@export var auto_sacrifice_when_cost_met: bool = false
@export var enable_undo_key: bool = true

var is_processing: bool = false
var is_committing: bool = false


func _ready() -> void:
	_connect_hand()
	_connect_selection_root()
	_update_warning()
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
	_update_warning()
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

		_remove_card_from_source(card)

	committer.commit_cards(cards)

	is_committing = false

	sacrifice_committed.emit(cards)
	_hide_warning()
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
	var has_pending_revenant := _cards_include_revenant(selected_cards)

	for card in selected_cards:
		if card == null:
			continue

		if card == primed_card:
			continue

		var entry := _build_pending_entry(card)

		if entry.is_empty():
			continue

		entries.append(entry)

	if player_hand != null:
		player_hand.clear_sacrifice_selection()

	if sacrifice_selection_root != null:
		sacrifice_selection_root.clear_all()

	var pending_cards := pending_boat.begin_pending(primed_card, entries)

	if has_pending_revenant:
		_show_warning()
	else:
		_hide_warning()

	is_processing = false

	pending_sacrifice_started.emit(primed_card, pending_cards)
	_update_requirement_state()


func _build_pending_entry(card: CardRoot) -> Dictionary:
	if card == null:
		return {}

	if _is_hand_card(card):
		return {
			"card": card,
			"source": "hand",
			"index": player_hand.get_index_of_card(card)
		}

	if _is_board_card(card):
		return {
			"card": card,
			"source": "board",
			"slot": _get_card_slot(card)
		}

	return {}


func _remove_card_from_source(card: CardRoot) -> void:
	if card == null:
		return

	if _is_hand_card(card):
		player_hand.remove_card_from_hand(card)
		return

	var board_presence := _get_board_presence(card)

	if board_presence != null and board_presence.is_on_board():
		board_presence.leave_slot(card)


func _is_hand_card(card: CardRoot) -> bool:
	if player_hand == null:
		return false

	return player_hand.has_card(card)


func _is_board_card(card: CardRoot) -> bool:
	var board_presence := _get_board_presence(card)

	if board_presence == null:
		return false

	return board_presence.is_on_board()


func _get_card_slot(card: CardRoot) -> Slot:
	var board_presence := _get_board_presence(card)

	if board_presence == null:
		return null

	return board_presence.current_slot


func _get_board_presence(card: CardRoot) -> BoardPresence:
	if card == null:
		return null

	return card.get("board_presence") as BoardPresence


func _connect_hand() -> void:
	if player_hand == null:
		return

	if not player_hand.sacrifice_requested.is_connected(_on_sacrifice_requested):
		player_hand.sacrifice_requested.connect(_on_sacrifice_requested)

	if not player_hand.card_primed.is_connected(_on_card_primed):
		player_hand.card_primed.connect(_on_card_primed)

	if not player_hand.card_unprimed.is_connected(_on_card_unprimed):
		player_hand.card_unprimed.connect(_on_card_unprimed)

	if not player_hand.sacrifice_selection_changed.is_connected(_on_hand_selection_changed):
		player_hand.sacrifice_selection_changed.connect(_on_hand_selection_changed)


func _connect_selection_root() -> void:
	if sacrifice_selection_root == null:
		return

	if not sacrifice_selection_root.selection_changed.is_connected(_on_selection_root_changed):
		sacrifice_selection_root.selection_changed.connect(_on_selection_root_changed)


func _on_sacrifice_requested(
	primed_card: CardRoot,
	cards: Array[CardRoot]
) -> void:
	print(
		"SACRIFICE CONTROLLER RECEIVED | hand=",
		player_hand.name if player_hand != null else "null",
		" primed=",
		primed_card.card_name if primed_card != null else "null",
		" cards=",
		cards.size()
	)

	request_sacrifice()


func _on_card_primed(card: CardRoot) -> void:
	_update_requirement_state()

	if card == null:
		return

	if is_processing:
		return

	if pending_boat != null and pending_boat.has_pending():
		return

	if requirement == null:
		return

	var required := requirement.get_required_worth(card)

	if required > 0:
		return

	_begin_pending_sacrifice(card, [])


func _on_hand_selection_changed(cards: Array[CardRoot]) -> void:
	if sacrifice_selection_root != null:
		sacrifice_selection_root.set_hand_cards(cards)
		return

	if is_processing:
		return

	_update_warning()
	_update_requirement_state()
	_try_auto_sacrifice()


func _on_selection_root_changed(_cards: Array[CardRoot]) -> void:
	if is_processing:
		return

	_update_warning()
	_update_requirement_state()
	_try_auto_sacrifice()


func _on_card_unprimed(_card: CardRoot) -> void:
	if is_committing:
		return

	undo_pending_sacrifice()

	if player_hand != null:
		player_hand.clear_sacrifice_selection()

	if sacrifice_selection_root != null:
		sacrifice_selection_root.clear_all()

	_hide_warning()
	_update_requirement_state()


func _try_auto_sacrifice() -> void:
	if auto_sacrifice_when_cost_met:
		request_sacrifice()


func _update_warning() -> void:
	if revenant_warning == null:
		return

	revenant_warning.update_for_cards(_get_selected_cards())


func _show_warning() -> void:
	if revenant_warning != null:
		revenant_warning.show_warning()


func _hide_warning() -> void:
	if revenant_warning != null:
		revenant_warning.hide_warning()


func _cards_include_revenant(cards: Array[CardRoot]) -> bool:
	for card in cards:
		if card != null and card.is_revenant():
			return true

	return false


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
	if sacrifice_selection_root != null:
		return sacrifice_selection_root.get_selected_cards()

	if player_hand == null:
		return []

	return player_hand.get_selected_sacrifice_cards()

func get_pending_sacrifice_cards() -> Array[CardRoot]:
	if pending_boat == null:
		return []

	if not pending_boat.has_pending():
		return []

	return pending_boat.get_pending_cards()
