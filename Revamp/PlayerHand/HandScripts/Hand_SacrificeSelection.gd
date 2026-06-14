extends Node
class_name Hand_SacrificeSelection

signal hand_sacrifice_card_selected(card: CardRoot)
signal hand_sacrifice_card_deselected(card: CardRoot)
signal hand_sacrifice_selection_changed(cards: Array[CardRoot])
signal hand_sacrifice_selection_cleared

@export var drag_multi_select_enabled: bool = true
@export var drag_multi_select_button: MouseButton = MOUSE_BUTTON_LEFT

var card_spawner: Hand_CardSpawner = null

var selected_cards: Array[CardRoot] = []
var primed_card: CardRoot = null
var is_enabled: bool = false
var is_drag_multi_selecting: bool = false
var drag_seen_cards: Array[CardRoot] = []


func setup(source_card_spawner: Hand_CardSpawner) -> void:
	card_spawner = source_card_spawner

	if card_spawner == null:
		return

	if not card_spawner.card_removed.is_connected(_on_card_removed):
		card_spawner.card_removed.connect(_on_card_removed)

	if card_spawner.has_signal("card_added"):
		if not card_spawner.card_added.is_connected(_on_card_added):
			card_spawner.card_added.connect(_on_card_added)

	for card: CardRoot in card_spawner.get_cards():
		_connect_card_hover(card)


func _unhandled_input(event: InputEvent) -> void:
	if not drag_multi_select_enabled:
		return

	if not is_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index != drag_multi_select_button:
			return

		is_drag_multi_selecting = event.pressed
		drag_seen_cards.clear()


func set_enabled(value: bool) -> void:
	is_enabled = value

	if not is_enabled:
		is_drag_multi_selecting = false
		drag_seen_cards.clear()
		clear_selection()


func set_primed_card(card: CardRoot) -> void:
	primed_card = card

	if selected_cards.has(primed_card):
		deselect_card(primed_card)


func handle_card_pressed(card: CardRoot) -> void:
	if not is_enabled:
		return

	if selected_cards.has(card):
		deselect_card(card)
	else:
		select_card(card)


func handle_card_right_pressed(card: CardRoot) -> void:
	if not is_enabled:
		return

	deselect_card(card)


func select_card(card: CardRoot) -> void:
	if card == null:
		return

	if card == primed_card:
		return

	if selected_cards.has(card):
		return

	if not _is_card_in_hand(card):
		return

	selected_cards.append(card)
	card.set_sacrifice_selected(true)

	hand_sacrifice_card_selected.emit(card)
	_emit_selection_changed()


func deselect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not selected_cards.has(card):
		return

	selected_cards.erase(card)
	card.set_sacrifice_selected(false)

	hand_sacrifice_card_deselected.emit(card)
	_emit_selection_changed()


func clear_selection() -> void:
	for card in selected_cards.duplicate():
		if card == null:
			continue

		card.set_sacrifice_selected(false)
		card.stop_sacrifice_anticipation()

	selected_cards.clear()

	hand_sacrifice_selection_cleared.emit()
	_emit_selection_changed()


func get_selected_cards() -> Array[CardRoot]:
	return selected_cards.duplicate()


func _on_card_added(card: CardRoot) -> void:
	_connect_card_hover(card)


func _on_card_removed(card: CardRoot) -> void:
	if selected_cards.has(card):
		selected_cards.erase(card)
		_emit_selection_changed()

	_disconnect_card_hover(card)


func _connect_card_hover(card: CardRoot) -> void:
	if card == null:
		return

	if not card.hovered.is_connected(_on_card_hovered):
		card.hovered.connect(_on_card_hovered)


func _disconnect_card_hover(card: CardRoot) -> void:
	if card == null:
		return

	if card.hovered.is_connected(_on_card_hovered):
		card.hovered.disconnect(_on_card_hovered)


func _on_card_hovered(card: CardRoot) -> void:
	if not drag_multi_select_enabled:
		return

	if not is_enabled:
		return

	if not is_drag_multi_selecting:
		return

	if card == null:
		return

	if drag_seen_cards.has(card):
		return

	drag_seen_cards.append(card)
	select_card(card)


func _is_card_in_hand(card: CardRoot) -> bool:
	if card_spawner == null:
		return false

	return card_spawner.is_card_in_hand(card)


func _emit_selection_changed() -> void:
	hand_sacrifice_selection_changed.emit(get_selected_cards())
