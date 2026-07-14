extends Node
class_name BoardSacrificeDebugProbe

@export var slots_root: SlotsRoot
@export var slot_input_z_index: int = 100


func _ready() -> void:
	_force_slot_input_z_index()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_O:
		_debug_print_player_board_cards()

	if event.keycode == KEY_Z:
		_force_slot_input_z_index()


func _debug_print_player_board_cards() -> void:
	if slots_root == null:
		print("BOARD DEBUG BLOCKED: slots_root null")
		return

	var cards := slots_root.get_cards_for_owner(SlotRow.SlotOwner.PLAYER)

	print("PLAYER BOARD CARD COUNT: ", cards.size())

	for card: CardRoot in cards:
		print(
			"PLAYER BOARD CARD | card=",
			card.card_name,
			" parent=",
			card.get_parent().name if card.get_parent() != null else "null"
		)


func _force_slot_input_z_index() -> void:
	if slots_root == null:
		print("Z DEBUG BLOCKED: slots_root null")
		return

	var slots := slots_root.get_slots_for_owner(SlotRow.SlotOwner.PLAYER)
	slots.append_array(slots_root.get_slots_for_owner(SlotRow.SlotOwner.OPPONENT))

	for slot: Slot in slots:
		if slot == null:
			continue

		slot.z_index = slot_input_z_index
		slot.z_as_relative = false

		var slot_input := slot.get_node_or_null("SlotInput") as SlotInput

		if slot_input != null and slot_input.click_area != null:
			slot_input.click_area.z_index = slot_input_z_index
			slot_input.click_area.z_as_relative = false
			print("SLOT Z SET | slot=", slot.name, " click_area=", slot_input.click_area.name, " z=", slot_input_z_index)
		else:
			print("SLOT Z SET BUT NO SLOT INPUT | slot=", slot.name, " z=", slot_input_z_index)
