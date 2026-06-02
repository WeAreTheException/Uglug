extends Mutation
class_name SteroidMaxxing

@export var attack_bonus: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_remove_buffs(runtime)

	var source_card := runtime.owner_card

	if source_card == null:
		return

	if not source_card.is_on_board():
		return

	if source_card.slots_root == null:
		return

	var source_slot := source_card.get_current_slot()

	if source_slot == null:
		return

	var owner := source_card.slots_root.get_owner_of_slot(source_slot)
	var ally_slots := source_card.slots_root.player_slots

	if owner == SlotRow.SlotOwner.OPPONENT:
		ally_slots = source_card.slots_root.opponent_slots

	for slot in ally_slots:
		_apply_to_ally(runtime, source_card, slot)


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func _apply_to_ally(
	runtime: MutationRuntime,
	source_card: CardRoot,
	slot: Slot
) -> void:
	if runtime == null:
		return

	if source_card == null:
		return

	if slot == null:
		return

	var target_card := slot.current_card

	if target_card == null:
		return

	if target_card == source_card:
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

	var source_card := runtime.owner_card

	if source_card == null:
		return

	if source_card.slots_root == null:
		return

	_remove_from_slots(runtime, source_card.slots_root.player_slots)
	_remove_from_slots(runtime, source_card.slots_root.opponent_slots)


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
