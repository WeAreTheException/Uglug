extends Node
class_name DeathAnim

@export var fade_time: float = 0.25
@export var shrink_scale: Vector2 = Vector2(0.85, 0.85)
@export var rotate_degrees: float = 8.0


func play(card: Card) -> void:
	if card == null:
		return

	var start_scale := card.scale
	var start_rotation := card.rotation

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(card, "scale", shrink_scale, fade_time)
	tween.parallel().tween_property(card, "rotation", start_rotation + deg_to_rad(rotate_degrees), fade_time)
	tween.parallel().tween_property(card, "modulate:a", 0.0, fade_time)

	await tween.finished

	if is_instance_valid(card):
		card.scale = start_scale
