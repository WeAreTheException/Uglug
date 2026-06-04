extends RefCounted
class_name StatPopTween


static func play(
	node: Node,
	sprite: Sprite2D,
	new_texture: Texture2D,
	pop_scale: float,
	pop_up_time: float,
	pop_down_time: float
) -> void:
	if node == null:
		return

	if sprite == null:
		return

	var original_scale: Vector2 = sprite.scale
	var target_scale: Vector2 = original_scale * pop_scale

	var tween := node.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(sprite, "scale", target_scale, pop_up_time)

	tween.tween_callback(func() -> void:
		sprite.texture = new_texture
	)

	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "scale", original_scale, pop_down_time)
