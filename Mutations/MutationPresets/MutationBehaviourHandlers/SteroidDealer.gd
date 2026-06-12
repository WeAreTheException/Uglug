extends Mutation
class_name SteroidDealer

@export var attack_bonus: int = 1
@export var health_bonus: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	_clear(runtime)

	var source_card := runtime.owner_card if runtime != null else null

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
	var left := source_card.slots_root.get_slot(owner, source_slot.slot_index - 1)
	var right := source_card.slots_root.get_slot(owner, source_slot.slot_index + 1)

	_apply_to_slot(runtime, left)
	_apply_to_slot(runtime, right)


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board(runtime: MutationRuntime) -> void:
	_clear(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	_clear(runtime)


func _apply_to_slot(runtime: MutationRuntime, slot: Slot) -> void:
	if slot == null:
		return

	var target := slot.current_card

	if target == null:
		return

	if target.stats == null:
		return

	_add_modifier(runtime, target, "attack", attack_bonus)
	_add_modifier(runtime, target, "health", health_bonus)


func _add_modifier(
	runtime: MutationRuntime,
	target: CardRoot,
	stat_name: String,
	amount: int
) -> void:
	if amount == 0:
		return

	var modifier := StatModifier.new()
	modifier.stat_name = stat_name
	modifier.amount = amount
	modifier.duration_type = StatModifier.DurationType.AURA
	modifier.source = runtime
	modifier.is_active = true

	target.stats.add_modifier(modifier)


func _clear(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	var source_card := runtime.owner_card

	if source_card == null:
		return

	if source_card.slots_root == null:
		return

	for slot in source_card.slots_root.get_all_slots():
		if slot == null:
			continue

		var card := slot.current_card

		if card == null:
			continue

		if card.stats == null:
			continue

		card.stats.remove_modifiers_from_source(runtime)
