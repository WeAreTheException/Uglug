extends Mutation
class_name RoyalPheromones

@export var worker_card_name: String = "Worker Ant"
@export var attack_bonus: int = 1
@export var health_bonus: int = 1
@export var minimum_health_after_buff_removed: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_remove_buffs(runtime)

	var queen := runtime.owner_card

	if queen == null:
		return

	if not queen.is_on_board():
		return

	if queen.slots_root == null:
		return

	var queen_slot := queen.get_current_slot()

	if queen_slot == null:
		return

	var owner := queen.slots_root.get_owner_of_slot(queen_slot)
	var ally_slots := queen.slots_root.get_slots_for_owner(owner)

	for slot in ally_slots:
		_apply_to_worker(runtime, slot)


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func _apply_to_worker(runtime: MutationRuntime, slot: Slot) -> void:
	if slot == null:
		return

	var target_card := slot.current_card

	if target_card == null:
		return

	if target_card.stats == null:
		return

	if target_card.card_name != worker_card_name:
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

	var queen := runtime.owner_card

	if queen == null:
		return

	if queen.slots_root == null:
		return

	_remove_from_slots(runtime, queen.slots_root.player_slots)
	_remove_from_slots(runtime, queen.slots_root.opponent_slots)


func _remove_from_slots(runtime: MutationRuntime, slots: Array[Slot]) -> void:
	for slot in slots:
		if slot == null:
			continue

		var target_card := slot.current_card

		if target_card == null:
			continue

		if target_card.stats == null:
			continue

		var health_before_removal := target_card.stats.get_health()

		target_card.stats.remove_modifiers_from_source(runtime)

		var health_after_removal := target_card.stats.get_health()

		if health_before_removal > 0 and health_after_removal <= 0:
			target_card.stats.heal(minimum_health_after_buff_removed)
