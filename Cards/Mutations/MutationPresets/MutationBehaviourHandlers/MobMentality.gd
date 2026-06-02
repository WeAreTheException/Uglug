extends Mutation
class_name MobMentality

@export var attack_bonus_per_ally: int = 1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_remove_buff(runtime)

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

	var ally_count := _count_ally_cards(ally_slots)

	var bonus := ally_count * attack_bonus_per_ally

	if bonus <= 0:
		return

	var modifier := StatModifier.new()
	modifier.stat_name = "attack"
	modifier.amount = bonus
	modifier.source = runtime
	modifier.is_active = true

	source_card.stats.add_modifier(modifier)


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_buff(runtime)


func _count_ally_cards(slots: Array[Slot]) -> int:
	var count := 0

	for slot in slots:
		if slot == null:
			continue

		if slot.current_card != null:
			count += 1

	return count


func _remove_buff(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	var source_card := runtime.owner_card

	if source_card == null:
		return

	if source_card.stats == null:
		return

	source_card.stats.remove_modifiers_from_source(runtime)
