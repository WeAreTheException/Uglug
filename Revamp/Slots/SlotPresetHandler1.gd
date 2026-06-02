extends Node
class_name SlotPresetHandler1

var slots_root: SlotsRoot = null


func setup(new_slots_root: SlotsRoot) -> void:
	slots_root = new_slots_root
	print("SlotPresetHandler1 setup. slots_root = ", slots_root)


func spawn_all_presets() -> void:
	print("SlotPresetHandler1 spawn_all_presets")

	if slots_root == null:
		print("blocked: slots_root null")
		return

	for slot in slots_root.player_slots:
		_spawn_preset_for_slot(slot)

	for slot in slots_root.opponent_slots:
		_spawn_preset_for_slot(slot)
	
	slots_root.refresh_board_mutations()


func _spawn_preset_for_slot(slot: Slot) -> void:
	print("checking slot: ", slot)

	if slot == null:
		return

	if not slot.is_empty():
		print("blocked: slot not empty ", slot.name)
		return

	if slots_root.card_scene == null:
		print("blocked: card_scene null")
		return

	var data := slots_root.get_preset_for_slot(slot)

	if data == null:
		print("blocked: no preset for slot ", slot.name)
		return

	print("spawning preset card: ", data.name, " into ", slot.name)

	var card := slots_root.card_scene.instantiate() as CardRoot

	if card == null:
		push_error("SlotPresetHandler1 blocked: card_scene root is not CardRoot.")
		return

	slot.add_child(card)
	card.position = Vector2.ZERO
	card.setup(data)
	card.setup_board_context(slots_root)

	if card.board_presence != null:
		card.board_presence.enter_slot(slot, card)
	else:
		slot.assign_card(card)
