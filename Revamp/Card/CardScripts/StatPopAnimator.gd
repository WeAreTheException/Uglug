extends RefCounted
class_name StatPopAnimator


static func play(
	node: Node,
	sprite: Sprite2D,
	original_scale: Vector2,
	pop_scale: float,
	pop_up_time: float,
	pop_down_time: float,
	swap_callback: Callable
) -> Tween:
	if node == null:
		return null

	if sprite == null:
		return null

	var tween := node.create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"scale",
		original_scale * pop_scale,
		pop_up_time
	)

	tween.tween_callback(func() -> void:
		if swap_callback.is_valid():
			swap_callback.call()
	)

	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		sprite,
		"scale",
		original_scale,
		pop_down_time
	)

	return tween
