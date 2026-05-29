extends Node
class_name CardFeedback

@export var card: CardRoot

@export var feedback_database: CardFeedbackDatabase

@export var position_feedback: PositionFeedback
@export var scale_feedback: ScaleFeedback
@export var shadow_feedback: ShadowFeedback

@export var enable_debug_key: bool = true
@export var debug_feedback_key: String = "generic"

var is_hovered: bool = false
var is_pressed: bool = false
var is_hand_selected: bool = false


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot

	if card == null:
		return

	if position_feedback != null:
		position_feedback.setup(card)

	if scale_feedback != null:
		scale_feedback.setup(card)

	if shadow_feedback != null:
		shadow_feedback.setup()

	card.hovered.connect(_on_card_hovered)
	card.unhovered.connect(_on_card_unhovered)
	card.pressed.connect(_on_card_pressed)
	card.released.connect(_on_card_released)


func _input(event: InputEvent) -> void:
	if not enable_debug_key:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			play_feedback(debug_feedback_key)


func play_feedback(feedback_key: String) -> void:
	if feedback_database == null:
		print("feedback blocked: database missing")
		return

	var feedback_data := feedback_database.get_feedback(feedback_key)

	if feedback_data == null:
		print("feedback blocked: no feedback for key: ", feedback_key)
		return

	play_feedback_data(feedback_data)


func play_feedback_data(feedback_data: CardFeedbackData) -> void:
	if feedback_data == null:
		return

	if position_feedback != null:
		position_feedback.move_to_offset(
			feedback_data.position_offset,
			feedback_data.position_time
		)

	if scale_feedback != null:
		scale_feedback.scale_to(
			feedback_data.scale_multiplier,
			feedback_data.scale_time
		)

	if shadow_feedback != null:
		shadow_feedback.fade_to(
			feedback_data.shadow_alpha,
			feedback_data.shadow_time
		)


func set_hand_selected(value: bool) -> void:
	is_hand_selected = value

	if is_hand_selected:
		play_feedback("hand_selected")
	else:
		play_feedback("neutral")


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true
	play_feedback("hover")


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false

	if is_hand_selected:
		play_feedback("hand_selected")
	else:
		play_feedback("neutral")


func _on_card_pressed(_card: CardRoot) -> void:
	is_pressed = true
	play_feedback("pressed")


func _on_card_released(_card: CardRoot) -> void:
	is_pressed = false

	if is_hand_selected:
		play_feedback("hand_selected")
	elif is_hovered:
		play_feedback("hover")
	else:
		play_feedback("neutral")
