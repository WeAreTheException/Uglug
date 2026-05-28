extends Node
class_name HurtAnim

@export var shake_distance: float = 10.0
@export var shake_time: float = 0.04


func play(card: Card) -> void:
	if card == null:
		return

	var start_pos := card.position

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(card, "position", start_pos + Vector2(-shake_distance, 0), shake_time)
	tween.tween_property(card, "position", start_pos + Vector2(shake_distance, 0), shake_time)
	tween.tween_property(card, "position", start_pos, shake_time)

	await tween.finished
