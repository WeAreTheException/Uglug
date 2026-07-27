extends Mutation
class_name SteroidMaxxing

@export var attack_bonus: int = 1
@export var health_bonus: int = 1
@export var minimum_health_after_buff_removed: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_remove_buffs(runtime)

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
	var ally_slots: Array[Slot] = source_card.slots_root.get_slots_for_owner(owner)

	for slot: Slot in ally_slots:
		_apply_to_ally(runtime, source_card, slot)


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func _apply_to_ally(
	runtime: MutationRuntime,
	source_card: CardRoot,
	slot: Slot
) -> void:
	if slot == null:
		return

	var target_card: CardRoot = slot.current_card

	if target_card == null:
		return

	if not is_instance_valid(target_card):
		return

	if target_card == source_card:
		return

	if target_card.stats == null:
		return

	_add_modifier(runtime, target_card, "attack", attack_bonus)
	_add_modifier(runtime, target_card, "health", health_bonus)


func _add_modifier(
	runtime: MutationRuntime,
	target_card: CardRoot,
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

	target_card.stats.add_modifier(modifier)


func _remove_buffs(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	var source_card: CardRoot = runtime.owner_card

	if source_card == null:
		return

	if not is_instance_valid(source_card):
		return

	if source_card.slots_root == null:
		return

	_remove_from_slots(runtime, source_card.slots_root.player_slots)
	_remove_from_slots(runtime, source_card.slots_root.opponent_slots)


func _remove_from_slots(runtime: MutationRuntime, slots: Array[Slot]) -> void:
	for slot: Slot in slots:
		if slot == null:
			continue

		var target_card: CardRoot = slot.current_card

		if target_card == null:
			continue

		if not is_instance_valid(target_card):
			continue

		if target_card.stats == null:
			continue

		var health_before_removal: int = target_card.stats.get_health()

		target_card.stats.remove_modifiers_from_source(runtime)

		var health_after_removal: int = target_card.stats.get_health()

		if health_before_removal > 0 and health_after_removal <= 0:
			target_card.stats.heal(minimum_health_after_buff_removed)
