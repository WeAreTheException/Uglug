extends Node
class_name SacrificeHandler

signal sacrifice_selection_changed(current_worth: int, required_worth: int)
signal sacrifice_requirement_met(current_worth: int, required_worth: int)
signal sacrifice_requirement_unmet(current_worth: int, required_worth: int)
signal sacrifice_card_selected(card: CardRoot)
signal sacrifice_card_deselected(card: CardRoot)

@export var player_hand_root: PlayerHandRoot
@export var session: SacrificeSession
@export var selection: SacrificeSelection


func _ready() -> void:
	if player_hand_root == null:
		return

	if session == null:
		session = $SacrificeSession as SacrificeSession

	if selection == null:
		selection = $SacrificeSelection as SacrificeSelection

	player_hand_root.card_primed.connect(_on_card_primed)
	player_hand_root.card_unprimed.connect(_on_card_unprimed)
	player_hand_root.card_added.connect(_on_card_added)
	player_hand_root.card_removed.connect(_on_card_removed)

	for card in player_hand_root.get_cards():
		_connect_card(card)


func _on_card_primed(card: CardRoot) -> void:
	_clear_all()

	session.start(card, card.get_sacrifice_cost())

	for hand_card in player_hand_root.get_cards():
		_connect_card(hand_card)

	_update_state()


func _on_card_unprimed(_card: CardRoot) -> void:
	_clear_all()


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if selection.remove_card(card):
		_apply_selected_visual(card, false)
		_sync_session_worth()
		_update_state()


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	if not card.right_pressed.is_connected(_on_card_right_pressed):
		card.right_pressed.connect(_on_card_right_pressed)


func _on_card_pressed(card: CardRoot) -> void:
	if not selection.can_select(card, session):
		return

	selection.select_card(card, card.get_sacrifice_worth())
	_sync_session_worth()

	_apply_selected_visual(card, true)

	sacrifice_card_selected.emit(card)
	_update_state()


func _on_card_right_pressed(card: CardRoot) -> void:
	if not session.is_active:
		return

	if not selection.has_card(card):
		return

	selection.deselect_card(card)
	_sync_session_worth()

	_apply_selected_visual(card, false)

	sacrifice_card_deselected.emit(card)
	_update_state()


func _sync_session_worth() -> void:
	session.set_current_worth(selection.current_worth)


func _update_state() -> void:
	sacrifice_selection_changed.emit(session.current_worth, session.required_worth)

	if session.is_requirement_met():
		sacrifice_requirement_met.emit(session.current_worth, session.required_worth)
	else:
		sacrifice_requirement_unmet.emit(session.current_worth, session.required_worth)


func _clear_all() -> void:
	if player_hand_root != null:
		for card in player_hand_root.get_cards():
			_apply_selected_visual(card, false)

	selection.clear()
	session.clear()

	_update_state()


func _apply_selected_visual(card: CardRoot, value: bool) -> void:
	if card == null:
		return

	card.set_sacrifice_selected(value)

	if not value:
		card.stop_sacrifice_anticipation()
