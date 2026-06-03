extends Node
class_name CardFeedback

@export var card: CardRoot
@export var hover_feedback: CardHoverFeedback
@export var select_feedback: CardSelectFeedback

var is_hover_focused: bool = false
var is_dragging: bool = false
var is_prime_selected: bool = false


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
		_apply_hover(false)
		_apply_selected(false)
		return

	var should_select := is_dragging or is_prime_selected

	if should_select:
		_apply_hover(false)
		_apply_selected(true)
		return

	_apply_selected(false)
	_apply_hover(is_hover_focused)


func _apply_hover(value: bool) -> void:
	if hover_feedback == null:
		return

	hover_feedback.set_enabled(value)

	if value:
		hover_feedback.play_hover()


func _apply_selected(value: bool) -> void:
	if select_feedback != null:
		select_feedback.set_selected(value)


func _can_use_hand_feedback() -> bool:
	if card == null:
		return false

	return not card.is_on_board()
