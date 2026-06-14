extends Node
class_name Sacrifice

signal sacrifice_anticipation_started(card: CardRoot)
signal sacrifice_anticipation_stopped(card: CardRoot)
signal marked_for_sacrifice(card: CardRoot)
signal unmarked_for_sacrifice(card: CardRoot)
signal pending_sacrifice_started(card: CardRoot)
signal pending_sacrifice_stopped(card: CardRoot)
signal committed_sacrifice_started(card: CardRoot)

@export var animation_runner: SacrificeAnimationRunner
@export var sacrifice_select_feedback: CardSelectFeedback

@export var pending_sacrifice_feedback: PendingSacrificeFeedback
@export var committed_sacrifice_feedback: CommittedSacrificeFeedback

var card: CardRoot = null
var is_anticipating: bool = false
var is_marked_for_sacrifice: bool = false
var is_pending_sacrifice: bool = false


func setup(source_card: CardRoot) -> void:
	card = source_card

	if pending_sacrifice_feedback != null:
		pending_sacrifice_feedback.setup(self)

	if committed_sacrifice_feedback != null:
		committed_sacrifice_feedback.setup(self)


func start_anticipation() -> void:
	if card == null:
		return

	if is_marked_for_sacrifice or is_pending_sacrifice:
		return

	is_anticipating = true

	if animation_runner != null:
		animation_runner.play_idle(card)

	sacrifice_anticipation_started.emit(card)


func stop_anticipation() -> void:
	if card == null:
		return

	is_anticipating = false
	is_marked_for_sacrifice = false

	if animation_runner != null:
		animation_runner.stop_all(card)

	if sacrifice_select_feedback != null:
		sacrifice_select_feedback.set_selected(false)

	sacrifice_anticipation_stopped.emit(card)


func set_marked_for_sacrifice(value: bool) -> void:
	if card == null:
		return

	if is_marked_for_sacrifice == value:
		return

	is_marked_for_sacrifice = value

	if sacrifice_select_feedback != null:
		sacrifice_select_feedback.set_selected(is_marked_for_sacrifice)

	if is_marked_for_sacrifice:
		if animation_runner != null:
			animation_runner.play_selected(card)

		marked_for_sacrifice.emit(card)
	else:
		if not is_pending_sacrifice and animation_runner != null:
			animation_runner.stop_all(card)

		unmarked_for_sacrifice.emit(card)


func set_pending_sacrifice(value: bool) -> void:
	if card == null:
		return

	if is_pending_sacrifice == value:
		return

	is_pending_sacrifice = value

	if pending_sacrifice_feedback != null:
		pending_sacrifice_feedback.set_pending(card, is_pending_sacrifice)

	if is_pending_sacrifice:
		is_marked_for_sacrifice = true

		if sacrifice_select_feedback != null:
			sacrifice_select_feedback.set_selected(true)

		if animation_runner != null:
			animation_runner.play_selected(card)

		pending_sacrifice_started.emit(card)
	else:
		is_marked_for_sacrifice = false

		if sacrifice_select_feedback != null:
			sacrifice_select_feedback.set_selected(false)

		if animation_runner != null:
			animation_runner.stop_all(card)

		pending_sacrifice_stopped.emit(card)


func play_committed_sacrifice() -> void:
	if card == null:
		return

	stop_anticipation()
	set_pending_sacrifice(false)

	if committed_sacrifice_feedback != null:
		committed_sacrifice_feedback.play(card)

	committed_sacrifice_started.emit(card)


func reset_sacrifice_state() -> void:
	stop_anticipation()
	set_pending_sacrifice(false)
