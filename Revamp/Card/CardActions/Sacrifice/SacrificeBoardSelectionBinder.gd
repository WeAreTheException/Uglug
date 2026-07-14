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

	print("SAC BOARD BINDER READY")


func _connect_slots_root() -> void:
	if slots_root == null:
		print("SAC BOARD BINDER BLOCKED: slots_root null")
		return

	if not slots_root.slot_clicked.is_connected(_on_slot_clicked):
		slots_root.slot_clicked.connect(_on_slot_clicked)

	print("SAC BOARD BINDER CONNECTED slot_clicked")


func _connect_player_hand() -> void:
	if player_hand == null:
		print("SAC BOARD BINDER BLOCKED: player_hand null")
		return

	if not player_hand.state_changed.is_connected(_on_hand_state_changed):
		player_hand.state_changed.connect(_on_hand_state_changed)

	print("SAC BOARD BINDER CONNECTED player_hand")


func _on_hand_state_changed(state_name: String) -> void:
	is_sacrifice_active = state_name.to_lower().contains("sacrifice")

	print("SAC BOARD ACTIVE = ", is_sacrifice_active, " state=", state_name)

	if not is_sacrifice_active and selection_root != null:
		selection_root.clear_board_cards()


func _on_slot_clicked(slot: Slot) -> void:
	print(
		"BOARD SACRIFICE CLICK SEEN | slot=",
		slot.name if slot != null else "null",
		" occupied=",
		slot.current_card != null if slot != null else false,
		" card=",
		slot.current_card.card_name if slot != null and slot.current_card != null else "null"
	)

	if selection_root == null:
		print("BOARD SACRIFICE BLOCKED: selection_root null")
		return

	if not is_sacrifice_active:
		print("BOARD SACRIFICE BLOCKED: sacrifice not active")
		return

	if slot == null:
		print("BOARD SACRIFICE BLOCKED: slot null")
		return

	if not _is_allowed_owner_slot(slot):
		print("BOARD SACRIFICE BLOCKED: wrong owner")
		return

	var card := slot.current_card

	if card == null:
		print("BOARD SACRIFICE BLOCKED: empty slot")
		return

	_toggle_board_card(card)


func _is_allowed_owner_slot(slot: Slot) -> bool:
	if slots_root == null:
		return false

	var allowed_slots := slots_root.get_slots_for_owner(allowed_owner)

	return allowed_slots.has(slot)


func _toggle_board_card(card: CardRoot) -> void:
	if selection_root.get_selected_cards().has(card):
		selection_root.remove_board_card(card)
		card.set_sacrifice_selected(false)
		print("BOARD MARTYR REMOVED | card=", card.card_name)
		return

	if selection_root.add_board_card(card):
		card.set_sacrifice_selected(true)
		print("BOARD MARTYR SELECTED | card=", card.card_name)
	else:
		print("BOARD MARTYR FAILED | card=", card.card_name)
