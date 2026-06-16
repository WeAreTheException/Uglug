extends Node
class_name SacrificeBoardSelectionBinder

@export var slots_root: SlotsRoot
@export var selection_root: SacrificeSelectionRoot
@export var player_hand: PlayerHandRoot

@export var allowed_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var print_debug: bool = true

var is_sacrifice_active: bool = false


func _ready() -> void:
	_connect_slots_root()
	_connect_player_hand()


func setup(
	source_slots_root: SlotsRoot,
	source_selection_root: SacrificeSelectionRoot,
	source_player_hand: PlayerHandRoot
) -> void:
	slots_root = source_slots_root
	selection_root = source_selection_root
	set_player_hand(source_player_hand)

	_connect_slots_root()


func set_player_hand(new_hand: PlayerHandRoot) -> void:
	if player_hand == new_hand:
		return

	_disconnect_player_hand()
	player_hand = new_hand
	_connect_player_hand()


func _connect_slots_root() -> void:
	if slots_root == null:
		return

	if not slots_root.slot_clicked.is_connected(_on_slot_clicked):
		slots_root.slot_clicked.connect(_on_slot_clicked)


func _connect_player_hand() -> void:
	if player_hand == null:
		return

	if not player_hand.hand_state_changed.is_connected(_on_hand_state_changed):
		player_hand.hand_state_changed.connect(_on_hand_state_changed)


func _disconnect_player_hand() -> void:
	if player_hand == null:
		return

	if player_hand.hand_state_changed.is_connected(_on_hand_state_changed):
		player_hand.hand_state_changed.disconnect(_on_hand_state_changed)


func _on_hand_state_changed(state_name: String) -> void:
	is_sacrifice_active = state_name.to_lower().contains("sacrifice")

	if not is_sacrifice_active and selection_root != null:
		selection_root.clear_board_cards()


func _on_slot_clicked(slot: Slot) -> void:
	if slot == null:
		return

	_print("BOARD SACRIFICE CLICK SEEN")

	if selection_root == null:
		_print("BOARD SACRIFICE BLOCKED: selection_root missing")
		return

	if not is_sacrifice_active:
		_print("BOARD SACRIFICE BLOCKED: sacrifice not active")
		return

	if not _is_allowed_slot(slot):
		_print("BOARD SACRIFICE BLOCKED: wrong owner")
		return

	var card := slot.current_card

	if card == null:
		_print("BOARD SACRIFICE BLOCKED: empty slot")
		return

	if _is_primed_card(card):
		_print("BOARD SACRIFICE BLOCKED: cannot sacrifice primed card")
		return

	_toggle_board_card(card)


func _toggle_board_card(card: CardRoot) -> void:
	if selection_root.get_selected_cards().has(card):
		selection_root.remove_board_card(card)
		card.set_sacrifice_selected(false)
		_print("BOARD SACRIFICE UNSELECTED: %s" % card.card_name)
		return

	if selection_root.add_board_card(card):
		card.set_sacrifice_selected(true)
		_print("BOARD SACRIFICE SELECTED: %s" % card.card_name)
		return

	card.set_sacrifice_selected(false)
	_print("BOARD SACRIFICE BLOCKED: worth limit")


func _is_allowed_slot(slot: Slot) -> bool:
	if slots_root == null:
		return false

	return slots_root.get_owner_of_slot(slot) == allowed_owner


func _is_primed_card(card: CardRoot) -> bool:
	if player_hand == null:
		return false

	return player_hand.get_primed_card() == card


func _print(message: String) -> void:
	if print_debug:
		print(message)
