extends Node
class_name SlotPresetHandler1

var slots_root: SlotsRoot = null


func setup(source_slots_root: SlotsRoot) -> void:
	slots_root = source_slots_root


func spawn_all_presets() -> void:
	if slots_root == null:
		return

	_spawn_presets_for_owner(SlotRow.SlotOwner.PLAYER)
	_spawn_presets_for_owner(SlotRow.SlotOwner.OPPONENT)

	slots_root.refresh_board_mutations()


func _spawn_presets_for_owner(owner: SlotRow.SlotOwner) -> void:
	for slot in slots_root.get_slots_for_owner(owner):
		_spawn_preset_for_slot(slot)


func _spawn_preset_for_slot(slot: Slot) -> void:
	if slot == null:
		return

	if not slot.is_empty():
		return

	if slots_root.card_scene == null:
		return

	var data := slots_root.get_preset_for_slot(slot)

	if data == null:
		return

	var card := slots_root.card_scene.instantiate() as CardRoot

	if card == null:
		push_error("SlotPresetHandler1 blocked: card_scene root is not CardRoot.")
		return

	_add_card_to_board(card, slot)
	card.setup(data)
	card.setup_board_context(slots_root)

	if card.board_presence != null:
		card.board_presence.enter_slot(slot, card)
	else:
		slot.assign_card(card)


func _add_card_to_board(card: CardRoot, slot: Slot) -> void:
	var parent := slots_root.spawned_card_parent

	if parent == null:
		parent = slot

	parent.add_child(card)
	card.global_position = slot.get_card_anchor_global_position()
	card.rotation_degrees = 0.0
