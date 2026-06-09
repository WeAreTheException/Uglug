extends Mutation
class_name Heckler

@export var attack_debuff: int = -1


func refresh_board_effect(runtime: MutationRuntime) -> void:
	if runtime == null:
		return

	_remove_debuff(runtime)

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

	var opposing_slot := card.slots_root.get_opposing_slot(current_slot)

	if opposing_slot == null:
		return

	var opposing_card := opposing_slot.current_card

	if opposing_card == null:
		return

	if opposing_card.stats == null:
		return

	_apply_debuff(runtime, opposing_card)


func refresh_board_context(runtime: MutationRuntime) -> void:
	refresh_board_effect(runtime)


func on_left_board(runtime: MutationRuntime) -> void:
	_remove_debuff(runtime)


func on_left_board_context(runtime: MutationRuntime) -> void:
	_remove_debuff(runtime)


func _apply_debuff(runtime: MutationRuntime, target_card: CardRoot) -> void:
	var modifier := StatModifier.new()
	modifier.stat_name = "attack"
	modifier.amount = attack_debuff
	modifier.duration_type = StatModifier.DurationType.AURA
	modifier.source = runtime
	modifier.is_active = true

	target_card.stats.add_modifier(modifier)


func _remove_debuff(runtime: MutationRuntime) -> void:
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
