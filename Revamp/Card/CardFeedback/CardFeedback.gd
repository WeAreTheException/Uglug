extends Node
class_name CardFeedback

@export var card: CardRoot
@export var hover_feedback: CardHoverFeedback
@export var select_feedback: CardSelectFeedback
@export var outline_feedback: CardOutlineFeedback

@export var print_hover_debug: bool = true

var is_hover_focused: bool = false
var is_dragging: bool = false
var is_prime_selected: bool = false


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot


func set_hover_focused(value: bool) -> void:
	is_hover_focused = value

	if print_hover_debug:
		print("CARD HOVER FOCUSED: ", card.card_name if card != null else name, " = ", value)

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
		_apply_outline(false, false)
		return

	var should_select := is_dragging or is_prime_selected

	_apply_selected(should_select)
	_apply_hover(is_hover_focused and not should_select)
	_apply_outline(is_hover_focused, should_select)


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


func _apply_outline(hovered: bool, selected: bool) -> void:
	if outline_feedback == null:
		return

	outline_feedback.set_hovered(hovered)
	outline_feedback.set_selected(selected)


func _can_use_hand_feedback() -> bool:
	if card == null:
		return false

	return not card.is_on_board()
