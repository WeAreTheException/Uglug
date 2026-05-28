extends Node
class_name CardFeedback

@export var card: CardRoot

@export var position_feedback: PositionFeedback
@export var scale_feedback: ScaleFeedback
@export var shadow_feedback: ShadowFeedback

@export var hover_offset: Vector2 = Vector2(0, -18)
@export var pressed_offset: Vector2 = Vector2(0, -34)
@export var hand_selected_offset: Vector2 = Vector2(0, -24)

@export var hover_scale: Vector2 = Vector2(1.04, 1.04)
@export var pressed_scale: Vector2 = Vector2(1.08, 1.08)
@export var hand_selected_scale: Vector2 = Vector2(1.07, 1.07)

@export var hover_shadow_alpha: float = 0.0
@export var pressed_shadow_alpha: float = 0.45
@export var hand_selected_shadow_alpha: float = 0.35

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


func set_hand_selected(value: bool) -> void:
	is_hand_selected = value
	_apply_feedback()


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true
	_apply_feedback()


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
	_apply_feedback()


func _on_card_pressed(_card: CardRoot) -> void:
	is_pressed = true
	_apply_feedback()


func _on_card_released(_card: CardRoot) -> void:
	is_pressed = false
	_apply_feedback()


func _apply_feedback() -> void:
	var target_offset := Vector2.ZERO
	var target_scale := Vector2.ONE
	var target_shadow_alpha := 0.0

	if is_hand_selected:
		target_offset += hand_selected_offset
		target_scale = hand_selected_scale
		target_shadow_alpha = hand_selected_shadow_alpha

	if is_hovered:
		target_offset += hover_offset
		target_scale = hover_scale
		target_shadow_alpha = max(target_shadow_alpha, hover_shadow_alpha)

	if is_pressed:
		target_offset += pressed_offset
		target_scale = pressed_scale
		target_shadow_alpha = max(target_shadow_alpha, pressed_shadow_alpha)

	if position_feedback != null:
		position_feedback.move_to_offset(target_offset)

	if scale_feedback != null:
		scale_feedback.scale_to(target_scale)

	if shadow_feedback != null:
		shadow_feedback.fade_to(target_shadow_alpha)
