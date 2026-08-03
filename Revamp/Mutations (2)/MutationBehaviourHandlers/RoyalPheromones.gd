extends Mutation
class_name RoyalPheromones

@export var worker_card_name: String = "Worker Ant"
@export var attack_bonus: int = 1
@export var health_bonus: int = 1
@export var minimum_health_after_buff_removed: int = 1


func has_placement_buff_feedback() -> bool:
	return true


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	var queen: CardRoot = runtime.owner_card

	if queen == null:
		return

	if not is_instance_valid(queen):
		return

	if queen.slots_root == null:
		return

	if not queen.is_on_board():
		_remove_buffs(runtime)
		return

	var queen_slot: Slot = queen.get_current_slot()

	if queen_slot == null:
		_remove_buffs(runtime)
		return

	var owner: SlotRow.SlotOwner = (
		queen.slots_root.get_owner_of_slot(queen_slot)
	)

	var ally_slots: Array[Slot] = (
		queen.slots_root.get_slots_for_owner(owner)
	)

	var eligible_workers: Array[CardRoot] = (
		_get_eligible_workers(ally_slots)
	)

	_remove_from_ineligible_cards(
		runtime,
		queen.slots_root.player_slots,
		eligible_workers
	)

	_remove_from_ineligible_cards(
		runtime,
		queen.slots_root.opponent_slots,
		eligible_workers
	)

	for worker: CardRoot in eligible_workers:
		_ensure_modifier(
			runtime,
			worker,
			"attack",
			attack_bonus
		)

		_ensure_modifier(
			runtime,
			worker,
			"health",
			health_bonus
		)


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	_remove_buffs(runtime)


func _get_eligible_workers(
	slots: Array[Slot]
) -> Array[CardRoot]:
	var workers: Array[CardRoot] = []

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

		if target_card.card_name != worker_card_name:
			continue

		workers.append(target_card)

	return workers


func _ensure_modifier(
	runtime: MutationRuntime,
	target_card: CardRoot,
	stat_name: String,
	amount: int
) -> void:
	if amount == 0:
		return

	if _has_modifier(
		runtime,
		target_card,
		stat_name
	):
		return

	var modifier := StatModifier.new()
	modifier.stat_name = stat_name
	modifier.amount = amount
	modifier.duration_type = StatModifier.DurationType.AURA
	modifier.source = runtime
	modifier.is_active = true

	target_card.stats.add_modifier(modifier)


func _has_modifier(
	runtime: MutationRuntime,
	target_card: CardRoot,
	stat_name: String
) -> bool:
	if target_card == null:
		return false

	if target_card.stats == null:
		return false

	for modifier: StatModifier in target_card.stats.modifiers:
		if modifier == null:
			continue

		if modifier.source != runtime:
			continue

		if modifier.stat_name != stat_name:
			continue

		if modifier.duration_type != StatModifier.DurationType.AURA:
			continue

		if not modifier.is_active:
			continue

		return true

	return false


func _remove_from_ineligible_cards(
	runtime: MutationRuntime,
	slots: Array[Slot],
	eligible_workers: Array[CardRoot]
) -> void:
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

		if eligible_workers.has(target_card):
			continue

		if not _has_modifier_from_source(
			runtime,
			target_card
		):
			continue

		_remove_from_card(runtime, target_card)


func _has_modifier_from_source(
	runtime: MutationRuntime,
	target_card: CardRoot
) -> bool:
	if target_card == null:
		return false

	if target_card.stats == null:
		return false

	for modifier: StatModifier in target_card.stats.modifiers:
		if modifier == null:
			continue

		if modifier.source == runtime:
			return true

	return false


func _remove_buffs(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	var queen: CardRoot = runtime.owner_card

	if queen == null:
		return

	if not is_instance_valid(queen):
		return

	if queen.slots_root == null:
		return

	_remove_from_slots(
		runtime,
		queen.slots_root.player_slots
	)

	_remove_from_slots(
		runtime,
		queen.slots_root.opponent_slots
	)


func _remove_from_slots(
	runtime: MutationRuntime,
	slots: Array[Slot]
) -> void:
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

		if not _has_modifier_from_source(
			runtime,
			target_card
		):
			continue

		_remove_from_card(runtime, target_card)


func _remove_from_card(
	runtime: MutationRuntime,
	target_card: CardRoot
) -> void:
	var health_before_removal: int = (
		target_card.stats.get_health()
	)

	target_card.stats.remove_modifiers_from_source(runtime)

	var health_after_removal: int = (
		target_card.stats.get_health()
	)

	if (
		health_before_removal > 0
		and health_after_removal <= 0
	):
		target_card.stats.heal(
			minimum_health_after_buff_removed
		)
