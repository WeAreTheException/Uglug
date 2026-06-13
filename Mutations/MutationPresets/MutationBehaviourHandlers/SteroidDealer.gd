extends Mutation
class_name SteroidDealer

@export var attack_bonus: int = 1
@export var health_bonus: int = 1
@export var minimum_health_after_buff_removed: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_clear(runtime)

	var source_card: CardRoot = runtime.owner_card

	if source_card == null:
		return

	if not is_instance_valid(source_card):
		return

	if not source_card.is_on_board():
		return

	if source_card.slots_root == null:
		return

	var source_slot: Slot = source_card.get_current_slot()

	if source_slot == null:
		return

	var owner: SlotRow.SlotOwner = source_card.slots_root.get_owner_of_slot(source_slot)
	var left: Slot = source_card.slots_root.get_slot(owner, source_slot.slot_index - 1)
	var right: Slot = source_card.slots_root.get_slot(owner, source_slot.slot_index + 1)

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

	var target: CardRoot = slot.current_card

	if target == null:
		return

	if not is_instance_valid(target):
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

	var source_card: CardRoot = runtime.owner_card

	if source_card == null:
		return

	if not is_instance_valid(source_card):
		return

	if source_card.slots_root == null:
		return

	for slot: Slot in source_card.slots_root.get_all_slots():
		if slot == null:
			continue

		var card: CardRoot = slot.current_card

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if card.stats == null:
			continue

		var health_before_removal: int = card.stats.get_health()

		card.stats.remove_modifiers_from_source(runtime)

		var health_after_removal: int = card.stats.get_health()

		if health_before_removal > 0 and health_after_removal <= 0:
			card.stats.heal(minimum_health_after_buff_removed)
