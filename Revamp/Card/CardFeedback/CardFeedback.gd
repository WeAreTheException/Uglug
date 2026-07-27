extends Node
class_name CardFeedback

@export var card: CardRoot
@export var hover_feedback: CardHoverFeedback
@export var select_feedback: CardSelectFeedback
@export var outline_feedback: CardOutlineFeedback

var is_hover_focused: bool = false
var is_dragging: bool = false
var is_prime_selected: bool = false
var is_martyr_selected: bool = false


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot


func set_hover_focused(value: bool) -> void:
	is_hover_focused = value
	_refresh()


func set_drag_feedback(value: bool) -> void:
	is_dragging = value
	_refresh()


func set_prime_select_feedback(value: bool) -> void:
	is_prime_selected = value
	_refresh()


func set_martyr_selected(value: bool) -> void:
	is_martyr_selected = value
	_refresh()


func clear_all() -> void:
	is_hover_focused = false
	is_dragging = false
	is_prime_selected = false
	is_martyr_selected = false
	_refresh()


func _refresh() -> void:
	if card == null:
		_apply_hover(false)
		_apply_selected(false)
		_apply_outline(false, false, false)
		return

	var can_use_hand_feedback: bool = (
		_can_use_hand_feedback()
	)

	var should_select: bool = (
		can_use_hand_feedback
		and (
			is_dragging
			or is_prime_selected
		)
	)

	var should_play_hover_motion: bool = (
		can_use_hand_feedback
		and is_hover_focused
		and not should_select
		and not is_martyr_selected
	)

	var should_show_hover_outline: bool = (
		is_hover_focused
	)

	_apply_selected(
		should_select
	)

	_apply_hover(
		should_play_hover_motion
	)

	_apply_outline(
		should_show_hover_outline,
		should_select,
		is_martyr_selected
	)


func _apply_hover(value: bool) -> void:
	if hover_feedback == null:
		return

	hover_feedback.set_enabled(value)

	if value:
		hover_feedback.play_hover()
	else:
		hover_feedback.play_unhover()


func _apply_selected(value: bool) -> void:
	if select_feedback != null:
		select_feedback.set_selected(value)


func _apply_outline(
	hovered: bool,
	selected: bool,
	martyr: bool
) -> void:
	if outline_feedback == null:
		return

	outline_feedback.set_hovered(hovered)
	outline_feedback.set_selected(selected)
	outline_feedback.set_martyr(martyr)


func _can_use_hand_feedback() -> bool:
	if card == null:
		return false

	return not card.is_on_board()
