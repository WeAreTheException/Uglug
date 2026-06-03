extends Node
class_name Sacrifice

signal sacrifice_anticipation_started(card: CardRoot)
signal sacrifice_anticipation_stopped(card: CardRoot)
signal sacrifice_selected(card: CardRoot)
signal sacrifice_deselected(card: CardRoot)

@export var animation_runner: SacrificeAnimationRunner
@export var sacrifice_select_feedback: CardSelectFeedback

var card: CardRoot = null
var is_anticipating := false
var is_selected_for_sacrifice := false


func _ready() -> void:
	card = _find_card_parent()


func start_anticipation() -> void:
	if card == null:
		return

	if is_selected_for_sacrifice:
		return

	is_anticipating = true

	if animation_runner != null:
		animation_runner.play_idle(card)

	sacrifice_anticipation_started.emit(card)


func stop_anticipation() -> void:
	if card == null:
		return

	is_anticipating = false
	is_selected_for_sacrifice = false

	if animation_runner != null:
		animation_runner.stop_all(card)

	if sacrifice_select_feedback != null:
		sacrifice_select_feedback.set_selected(false)

	sacrifice_anticipation_stopped.emit(card)


func set_selected_for_sacrifice(value: bool) -> void:
	if card == null:
		return

	if is_selected_for_sacrifice == value:
		return

	is_selected_for_sacrifice = value

	if sacrifice_select_feedback != null:
		sacrifice_select_feedback.set_selected(is_selected_for_sacrifice)

	if is_selected_for_sacrifice:
		if animation_runner != null:
			animation_runner.play_selected(card)

		sacrifice_selected.emit(card)
	else:
		if animation_runner != null:
			animation_runner.stop_all(card)

		sacrifice_deselected.emit(card)


func reset_sacrifice_state() -> void:
	stop_anticipation()


func _find_card_parent() -> CardRoot:
	var current := get_parent()

	while current != null:
		var found_card := current as CardRoot

		if found_card != null:
			return found_card

		current = current.get_parent()

	return null
