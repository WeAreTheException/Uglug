extends Node
class_name Hurt

signal hurt_started(context: DamageContext)
signal hurt_finished(context: DamageContext)

var card: CardRoot = null
var is_hurting := false

func setup(source_card: CardRoot) -> void:
	card = source_card

func receive_damage(context: DamageContext) -> int:
	if is_hurting or card == null or context == null:
		return 0
	context.target_card = card
	var final_damage := _modify_incoming_damage(context)
	context.final_amount = max(final_damage, 0)
	context.was_blocked = context.final_amount <= 0
	if context.was_blocked:
		return 0
	is_hurting = true
	hurt_started.emit(context)
	if card.feedback_root != null:
		await card.feedback_root.play_hurt(context)
	_apply_damage(context.final_amount)
	_notify_damaged_mutations(context)
	await _die_if_needed(context)
	is_hurting = false
	hurt_finished.emit(context)
	return context.final_amount

func _modify_incoming_damage(context: DamageContext) -> int:
	var result := context.base_amount
	var mutations := _get_mutations()
	if mutations == null:
		return result
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			result = runtime.mutation.modify_incoming_damage(
				runtime, card, context.source_card, result
			)
	return result

func _apply_damage(amount: int) -> void:
	if card.functionality_root != null and card.functionality_root.stats != null:
		card.functionality_root.stats.take_damage(amount)

func _notify_damaged_mutations(context: DamageContext) -> void:
	var mutations := _get_mutations()
	if mutations == null:
		return
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			runtime.mutation.on_damaged(card, context.source_card, context.final_amount)

func _die_if_needed(context: DamageContext) -> void:
	var stats := card.functionality_root.stats if card.functionality_root != null else null
	if stats != null and stats.is_dead():
		var death_context := DeathContext.new()
		death_context.setup_from_damage(card, context)
		await card.die(death_context)

func _get_mutations() -> CardMutations:
	if card == null or card.functionality_root == null:
		return null
	return card.functionality_root.mutations
