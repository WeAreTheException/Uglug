extends Mutation
class_name SteroidDealer

@export var attack_bonus: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_remove_buffs(runtime)

	var card := runtime.owner_card

	if card == null:
		return

	if not card.is_on_board():
		return

	if card.slots_root == null:
		return

	var current_slot := card.get_current_slot()

	if current_slot == null:
		return

	var owner := card.slots_root.get_owner_of_slot(current_slot)

	_apply_to_adjacent_slot(runtime, card.slots_root.get_slot(owner, current_slot.slot_index - 1))
	_apply_to_adjacent_slot(runtime, card.slots_root.get_slot(owner, current_slot.slot_index + 1))


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func _apply_to_adjacent_slot(runtime: MutationRuntime, slot: Slot) -> void:
	if runtime == null:
		return

	if slot == null:
		return

	var target_card := slot.current_card

	if target_card == null:
		return

	if target_card.stats == null:
		return

	var modifier := StatModifier.new()
	modifier.stat_name = "attack"
	modifier.amount = attack_bonus
	modifier.source = runtime
	modifier.is_active = true

	target_card.stats.add_modifier(modifier)


func _remove_buffs(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	var card := runtime.owner_card

	if card == null:
		return

	if card.slots_root == null:
		return

	_remove_from_slots(runtime, card.slots_root.player_slots)
	_remove_from_slots(runtime, card.slots_root.opponent_slots)


func _remove_from_slots(runtime: MutationRuntime, slots: Array[Slot]) -> void:
	for slot in slots:
		if slot == null:
			continue

		var target_card := slot.current_card

		if target_card == null:
			continue

		if target_card.stats == null:
			continue

		target_card.stats.remove_modifiers_from_source(runtime)
