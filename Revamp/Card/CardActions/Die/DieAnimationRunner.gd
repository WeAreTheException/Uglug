extends Node
class_name DieAnimationRunner

@export var fade_time: float = 0.25
@export var shrink_scale: Vector2 = Vector2(0.85, 0.85)
@export var rotate_degrees: float = 0.0


func play(card: CardRoot) -> void:
	if card == null:
		return

	var start_scale: Vector2 = card.scale
	var start_rotation: float = card.rotation
	var start_alpha: float = card.modulate.a

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(
		card,
		"scale",
		shrink_scale,
		fade_time
	)

	tween.parallel().tween_property(
		card,
		"rotation",
		start_rotation + deg_to_rad(rotate_degrees),
		fade_time
	)

	tween.parallel().tween_property(
		card,
		"modulate:a",
		0.0,
		fade_time
	)

	await tween.finished

	if is_instance_valid(card):
		card.scale = start_scale
		card.rotation = start_rotation
		card.modulate.a = start_alpha
