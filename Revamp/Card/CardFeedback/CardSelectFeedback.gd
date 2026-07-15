extends Node
class_name CardSelectFeedback

@export var target: Node2D
@export var extra_sprite: Sprite2D
@export var extra_area: Area2D
@export var shadow: CanvasItem
@export var select_audio: AudioStreamPlayer2D

@export var selected_offset: Vector2 = Vector2(0, -28)
@export var shadow_alpha: float = 0.45
@export var tween_time: float = 0.12

var base_position: Vector2 = Vector2.ZERO
var extra_sprite_base_position: Vector2 = Vector2.ZERO
var extra_area_base_position: Vector2 = Vector2.ZERO

var is_selected: bool = false
var tween: Tween = null


func _ready() -> void:
	if target != null:
		base_position = target.position

	if extra_sprite != null:
		extra_sprite_base_position = extra_sprite.position

	if extra_area != null:
		extra_area_base_position = extra_area.position

	if shadow != null:
		shadow.visible = true
		shadow.modulate.a = 0.0


func set_selected(value: bool) -> void:
	if target == null:
		return

	if value == is_selected:
		return

	is_selected = value

	if tween != null:
		tween.kill()

	var final_position := base_position
	var final_sprite_position := extra_sprite_base_position
	var final_area_position := extra_area_base_position
	var final_shadow_alpha := 0.0

	if is_selected:
		final_position = base_position + selected_offset
		final_sprite_position = extra_sprite_base_position + selected_offset
		final_area_position = extra_area_base_position + selected_offset
		final_shadow_alpha = shadow_alpha

		if select_audio != null:
			select_audio.stop()
			select_audio.play()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		target,
		"position",
		final_position,
		tween_time
	)

	if extra_sprite != null:
		tween.parallel().tween_property(
			extra_sprite,
			"position",
			final_sprite_position,
			tween_time
		)

	if extra_area != null:
		tween.parallel().tween_property(
			extra_area,
			"position",
			final_area_position,
			tween_time
		)

	if shadow != null:
		tween.parallel().tween_property(
			shadow,
			"modulate:a",
			final_shadow_alpha,
			tween_time
		)
