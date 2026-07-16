extends Node
class_name BuffedVfx

@export var sprite: Sprite2D

@export var rise_distance: float = 28.0
@export var duration: float = 0.35
@export var start_alpha: float = 1.0
@export var end_alpha: float = 0.0

var start_position: Vector2 = Vector2.ZERO
var start_scale: Vector2 = Vector2.ONE
var start_rotation: float = 0.0
var start_modulate: Color = Color.WHITE

var tween: Tween = null


func _ready() -> void:
	if sprite == null:
		return

	start_position = sprite.position
	start_scale = sprite.scale
	start_rotation = sprite.rotation
	start_modulate = sprite.modulate
	sprite.visible = false


func play(_card: CardRoot = null) -> void:
	if sprite == null:
		return

	if tween != null:
		tween.kill()
		tween = null

	sprite.visible = true
	sprite.position = start_position
	sprite.scale = start_scale
	sprite.rotation = start_rotation

	var start_color := start_modulate
	start_color.a = start_alpha
	sprite.modulate = start_color

	var end_position := start_position + Vector2(0.0, -rise_distance)

	var end_color := start_modulate
	end_color.a = end_alpha

	tween = sprite.create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		sprite,
		"position",
		end_position,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"modulate",
		end_color,
		duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	sprite.visible = false
	sprite.position = start_position
	sprite.scale = start_scale
	sprite.rotation = start_rotation
	sprite.modulate = start_modulate
	tween = null
