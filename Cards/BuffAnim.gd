extends Node
class_name BuffAnim

@export var grow_scale: Vector2 = Vector2(1.15, 1.15)

@export var scale_up_time: float = 0.12
@export var hold_time: float = 0.20
@export var scale_down_time: float = 0.12

@export var tremble_strength: float = 4.0
@export var tremble_speed: float = 0.02


func play(card: Card) -> void:
	if card == null:
		return

	var start_scale := card.scale
	var start_position := card.position

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)

	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", grow_scale, scale_up_time)

	await tween.finished

	var elapsed := 0.0

	while elapsed < hold_time:
		card.position = start_position + Vector2(
			randf_range(-tremble_strength, tremble_strength),
			randf_range(-tremble_strength, tremble_strength)
		)

		await get_tree().create_timer(tremble_speed).timeout
		elapsed += tremble_speed

	card.position = start_position

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(card, "scale", start_scale, scale_down_time)

	await tween.finished

	card.scale = start_scale
	card.position = start_position
