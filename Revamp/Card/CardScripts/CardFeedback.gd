extends Node
class_name CardFeedback

@export var card: CardRoot
@export var hover_feedback: CardHoverFeedback
@export var select_feedback: CardSelectFeedback

var is_hover_focused := false
var is_dragging := false
var is_prime_selected := false


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


func clear_all() -> void:
	is_hover_focused = false
	is_dragging = false
	is_prime_selected = false
	_refresh()


func _refresh() -> void:
	if not _can_use_hand_feedback():
		_apply_selected(false)
		_apply_hover(false)
		return

	var should_select := is_dragging or is_prime_selected

	_apply_selected(should_select)

	if should_select:
		_apply_hover(false, false)
	else:
		_apply_hover(is_hover_focused, true)


func _apply_selected(value: bool) -> void:
	if select_feedback != null:
		select_feedback.set_selected(value)


func _apply_hover(value: bool, reset_when_disabled: bool = true) -> void:
	if hover_feedback == null:
		return

	hover_feedback.set_enabled(value, reset_when_disabled)

	if value:
		hover_feedback.play_hover()


func _can_use_hand_feedback() -> bool:
	if card == null:
		return false

	return not card.is_on_board()
