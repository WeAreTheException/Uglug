extends Node
class_name CardFeedback

@export var card: CardRoot
@export var shadow_texture: TextureRect

@export var hover_offset: Vector2 = Vector2(0, -18)
@export var pressed_offset: Vector2 = Vector2(0, -34)

@export var hover_scale: Vector2 = Vector2(1.04, 1.04)
@export var pressed_scale: Vector2 = Vector2(1.08, 1.08)

@export var move_time: float = 0.12
@export var shadow_fade_time: float = 0.10

var base_position: Vector2
var base_scale: Vector2

var is_hovered: bool = false
var is_pressed: bool = false

var feedback_tween: Tween
var shadow_tween: Tween


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot

	if card == null:
		return

	base_position = card.position
	base_scale = card.scale

	if shadow_texture != null:
		shadow_texture.visible = true
		shadow_texture.modulate.a = 0.0

	card.hovered.connect(_on_card_hovered)
	card.unhovered.connect(_on_card_unhovered)
	card.pressed.connect(_on_card_pressed)
	card.released.connect(_on_card_released)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true
	_apply_feedback()


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false

	if not is_pressed:
		_apply_feedback()


func _on_card_pressed(_card: CardRoot) -> void:
	is_pressed = true
	_apply_feedback()


func _on_card_released(_card: CardRoot) -> void:
	is_pressed = false
	_apply_feedback()


func _apply_feedback() -> void:
	if feedback_tween != null:
		feedback_tween.kill()

	if shadow_tween != null:
		shadow_tween.kill()

	var target_position := base_position
	var target_scale := base_scale
	var target_shadow_alpha := 0.0

	if is_hovered:
		target_position += hover_offset
		target_scale = hover_scale

	if is_pressed:
		target_position += pressed_offset
		target_scale = pressed_scale
		target_shadow_alpha = 0.45

	feedback_tween = create_tween()

	feedback_tween.set_trans(Tween.TRANS_CUBIC)
	feedback_tween.set_ease(Tween.EASE_OUT)

	feedback_tween.tween_property(
		card,
		"position",
		target_position,
		move_time
	)

	feedback_tween.parallel().tween_property(
		card,
		"scale",
		target_scale,
		move_time
	)

	if shadow_texture != null:
		shadow_tween = create_tween()

		shadow_tween.set_trans(Tween.TRANS_CUBIC)
		shadow_tween.set_ease(Tween.EASE_OUT)

		shadow_tween.tween_property(
			shadow_texture,
			"modulate:a",
			target_shadow_alpha,
			shadow_fade_time
		)
