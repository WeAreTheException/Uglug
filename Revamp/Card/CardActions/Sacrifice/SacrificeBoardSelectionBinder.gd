extends Node
class_name SacrificeBoardSelectionBinder

@export var slots_root: SlotsRoot
@export var selection_root: SacrificeSelectionRoot
@export var player_hand: PlayerHandRoot
@export var allowed_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var debug_enabled: bool = true

var is_sacrifice_active: bool = false


func _ready() -> void:
	_connect_slots_root()
	_connect_player_hand()
	_refresh_sacrifice_active()

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

	if not player_hand.card_primed.is_connected(_on_card_primed):
		player_hand.card_primed.connect(_on_card_primed)

	if not player_hand.card_unprimed.is_connected(_on_card_unprimed):
		player_hand.card_unprimed.connect(_on_card_unprimed)

	print("SAC BOARD BINDER CONNECTED player_hand")


func _on_card_primed(card: CardRoot) -> void:
	is_sacrifice_active = card != null

	print(
		"SAC BOARD ACTIVE = ",
		is_sacrifice_active,
		" primed=",
		card.card_name if card != null else "null"
	)


func _on_card_unprimed(_card: CardRoot) -> void:
	is_sacrifice_active = false

	if selection_root != null:
		selection_root.clear_board_cards()

	print("SAC BOARD ACTIVE = false")


func _refresh_sacrifice_active() -> void:
	if player_hand == null:
		is_sacrifice_active = false
		return

	var primed_card := player_hand.get_primed_card()
	is_sacrifice_active = primed_card != null


func _on_slot_clicked(slot: Slot) -> void:
	print(
		"BOARD SACRIFICE CLICK SEEN | slot=",
		slot.name if slot != null else "null",
		" occupied=",
		slot.current_card != null if slot != null else false,
		" card=",
		slot.current_card.card_name if slot != null and slot.current_card != null else "null"
	)

	_refresh_sacrifice_active()

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

	if player_hand != null and card == player_hand.get_primed_card():
		print("BOARD SACRIFICE BLOCKED: cannot sacrifice primed card")
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
