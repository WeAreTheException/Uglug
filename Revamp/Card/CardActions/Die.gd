extends Node
class_name Die

signal die_started(context: DeathContext)
signal die_finished(context: DeathContext)

var card: CardRoot = null
var is_dying := false
var has_died := false

func setup(source_card: CardRoot) -> void:
	card = source_card

func play_die(context: DeathContext = null) -> void:
	if is_dying or has_died or card == null:
		return
	if context == null:
		context = DeathContext.new()
		context.dead_card = card
	has_died = true
	is_dying = true
	_notify_death_mutations(context)
	die_started.emit(context)
	if context.should_play_feedback and card.feedback_root != null:
		await card.feedback_root.play_death(context)
	_remove_from_board()
	is_dying = false
	die_finished.emit(context)
	if context.should_free_card and is_instance_valid(card):
		card.queue_free()

func _notify_death_mutations(context: DeathContext) -> void:
	if not context.should_trigger_death_mutations:
		return
	var mutations := _get_mutations()
	if mutations == null:
		return
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			runtime.mutation.on_death(card)

func _remove_from_board() -> void:
	if card != null:
		card.leave_slot(CardLeaveReason.DIED)

func _get_mutations() -> CardMutations:
	if card == null or card.functionality_root == null:
		return null
	return card.functionality_root.mutations
