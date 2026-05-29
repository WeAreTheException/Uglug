extends Node
class_name SlotPresetHandler

var slots_root: SlotsRoot = null


func setup(new_slots_root: SlotsRoot) -> void:
	slots_root = new_slots_root


func spawn_all_presets() -> void:
	if slots_root == null:
		return

	for slot in slots_root.player_slots:
		_spawn_preset_for_slot(slot)

	for slot in slots_root.opponent_slots:
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
		push_error("SlotPresetHandler blocked: card_scene root is not CardRoot.")
		return

	var parent := slots_root.spawned_card_parent

	if parent == null:
		parent = slots_root

	parent.add_child(card)

	card.global_position = slot.global_position
	card.setup(data)

	if card.board_presence != null:
		card.board_presence.enter_slot(slot, card)
	else:
		slot.assign_card(card)
