extends Mutation
class_name IDieYouDie


func on_death_started_context(
	_runtime: MutationRuntime,
	context: DeathContext
) -> void:
	if context == null:
		return

	await _kill_opposing_card(context.dead_card, context)


func on_death(_card: CardRoot) -> void:
	pass


func _kill_opposing_card(
	dead_card: CardRoot,
	source_context: DeathContext
) -> void:
	if dead_card == null:
		return

	if not is_instance_valid(dead_card):
		return

	if dead_card.slots_root == null:
		return

	var current_slot: Slot = dead_card.get_current_slot()

	if current_slot == null and source_context != null:
		current_slot = source_context.dead_slot

	if current_slot == null:
		return

	var opposing_slot: Slot = dead_card.slots_root.get_opposing_slot(current_slot)

	if opposing_slot == null:
		return

	var opposing_card: CardRoot = opposing_slot.current_card

	if opposing_card == null:
		return

	if not is_instance_valid(opposing_card):
		return

	if opposing_card.stats != null and opposing_card.stats.is_dead():
		return

	if opposing_card.die == null:
		return

	if opposing_card.die.is_unavailable_for_combat():
		return

	var death_context := DeathContext.new()
	death_context.setup(
		opposing_card,
		dead_card,
		MutationSource.MUTATION,
		self
	)

	await opposing_card.die.die_with_context(death_context)
