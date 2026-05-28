extends Node
class_name CardFeedback

@export var card: CardRoot

@export var hover_offset: Vector2 = Vector2(0, -18)
@export var hover_time: float = 0.12

@export var selected_scale: Vector2 = Vector2(1.08, 1.08)
@export var selected_time: float = 0.12

@export var shake_distance: float = 8.0
@export var shake_time: float = 0.04

var base_position: Vector2
var base_scale: Vector2

var is_hovered: bool = false
var is_selected: bool = false

var tween: Tween = null


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot

	if card == null:
		return

	base_position = card.position
	base_scale = card.scale

	card.hovered.connect(_on_card_hovered)
	card.unhovered.connect(_on_card_unhovered)


func set_hovered(value: bool) -> void:
	is_hovered = value
	_apply_base_feedback()


func set_selected(value: bool) -> void:
	is_selected = value
	_apply_base_feedback()


func play_shake() -> void:
	if card == null:
		return

	var start_position := card.position

	var shake_tween := create_tween()

	shake_tween.tween_property(
		card,
		"position",
		start_position + Vector2(shake_distance, 0),
		shake_time
	)

	shake_tween.tween_property(
		card,
		"position",
		start_position - Vector2(shake_distance, 0),
		shake_time
	)

	shake_tween.tween_property(
		card,
		"position",
		start_position,
		shake_time
	)


func _apply_base_feedback() -> void:
	if card == null:
		return

	if tween != null:
		tween.kill()

	var target_position := base_position
	var target_scale := base_scale

	if is_hovered:
		target_position += hover_offset

	if is_selected:
		target_scale = selected_scale

	tween = create_tween()

	tween.tween_property(
		card,
		"position",
		target_position,
		hover_time
	)

	tween.parallel().tween_property(
		card,
		"scale",
		target_scale,
		selected_time
	)


func _on_card_hovered(_card: CardRoot) -> void:
	set_hovered(true)


func _on_card_unhovered(_card: CardRoot) -> void:
	set_hovered(false)
