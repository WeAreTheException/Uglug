extends Node
class_name Sacrifice

signal sacrifice_anticipation_started(card: CardRoot)
signal sacrifice_anticipation_stopped(card: CardRoot)
signal marked_for_sacrifice(card: CardRoot)
signal unmarked_for_sacrifice(card: CardRoot)

@export var animation_runner: SacrificeAnimationRunner
@export var sacrifice_select_feedback: CardSelectFeedback

var card: CardRoot = null
var is_anticipating: bool = false
var is_marked_for_sacrifice: bool = false


func setup(source_card: CardRoot) -> void:
	card = source_card


func start_anticipation() -> void:
	if card == null:
		return

	if is_marked_for_sacrifice:
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
		if animation_runner != null:
			animation_runner.stop_all(card)

		unmarked_for_sacrifice.emit(card)


func reset_sacrifice_state() -> void:
	stop_anticipation()
