extends Node
class_name HurtSprite

@export var sprite: Sprite2D
@export var hurt_texture: Texture2D

@export var anchor: Node2D
@export var sprite_size: Vector2 = Vector2(48.0, 48.0)

@export var fade_time: float = 0.35
@export var start_alpha: float = 1.0
@export var start_effect_scale: float = 1.0
@export var end_effect_scale: float = 1.15

var tween: Tween
var base_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

	if sprite == null:
		return

	sprite.visible = false
	sprite.modulate.a = 0.0
	sprite.centered = true

	if hurt_texture != null:
		sprite.texture = hurt_texture

	_calculate_base_scale()


func play(_card: CardRoot) -> void:
	if sprite == null:
		return

	if anchor != null:
		sprite.global_position = anchor.global_position

	if tween != null:
		tween.kill()

	_calculate_base_scale()

	sprite.visible = true
	sprite.modulate.a = start_alpha
	sprite.scale = base_scale * start_effect_scale

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.parallel().tween_property(sprite, "scale", base_scale * end_effect_scale, fade_time)

	await tween.finished

	if sprite != null:
		sprite.visible = false


func _calculate_base_scale() -> void:
	base_scale = Vector2.ONE

	if sprite == null:
		return

	if sprite.texture == null:
		return

	var texture_size := sprite.texture.get_size()

	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	base_scale = Vector2(
		sprite_size.x / texture_size.x,
		sprite_size.y / texture_size.y
	)
