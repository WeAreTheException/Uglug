extends Node
class_name HurtSprite

@export var sprite: Sprite2D
@export var hurt_texture: Texture2D

@export var card_center_offset: Vector2 = Vector2.ZERO

@export var fade_time: float = 0.35
@export var start_alpha: float = 1.0
@export var start_scale: Vector2 = Vector2(1.0, 1.0)
@export var end_scale: Vector2 = Vector2(1.15, 1.15)

var tween: Tween


func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite") as Sprite2D

	if sprite != null:
		sprite.visible = false
		sprite.modulate.a = 0.0
		sprite.centered = true
		sprite.position = card_center_offset

		if hurt_texture != null:
			sprite.texture = hurt_texture


func play(_card: Card) -> void:
	if sprite == null:
		return

	if tween != null:
		tween.kill()

	sprite.position = card_center_offset
	sprite.visible = true
	sprite.modulate.a = start_alpha
	sprite.scale = start_scale

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.parallel().tween_property(sprite, "scale", end_scale, fade_time)

	await tween.finished

	sprite.visible = false
