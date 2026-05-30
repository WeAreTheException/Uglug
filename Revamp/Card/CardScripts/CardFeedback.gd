extends Node
class_name CardFeedback

@export var card: CardRoot
@export var hover_feedback: CardHoverFeedback
@export var select_feedback: CardSelectFeedback

var is_hovered := false
var is_selected := false


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot

	if card == null:
		return

	card.hovered.connect(_on_card_hovered)
	card.unhovered.connect(_on_card_unhovered)
	card.pressed.connect(_on_card_pressed)


func set_selected(value: bool) -> void:
	if not _can_use_hand_feedback():
		value = false

	is_selected = value

	if select_feedback != null:
		select_feedback.set_selected(is_selected)

	if hover_feedback != null:
		hover_feedback.set_enabled(not is_selected)

	if not is_selected and is_hovered and hover_feedback != null:
		hover_feedback.play_hover()


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true

	if not _can_use_hand_feedback():
		return

	if is_selected:
		return

	if hover_feedback != null:
		hover_feedback.play_hover()


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false

	if is_selected:
		return

	if hover_feedback != null:
		hover_feedback.play_unhover()


func _on_card_pressed(_card: CardRoot) -> void:
	if not _can_use_hand_feedback():
		return

	set_selected(not is_selected)


func _can_use_hand_feedback() -> bool:
	if card == null:
		return false

	return not card.is_on_board()
