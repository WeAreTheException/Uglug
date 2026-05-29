extends Node
class_name ShadowFeedback

@export var shadow_texture: TextureRect
@export var default_time: float = 0.10

var tween: Tween = null


func setup() -> void:
	if shadow_texture == null:
		return

	shadow_texture.visible = true
	shadow_texture.modulate.a = 0.0


func fade_to(alpha: float, duration: float = -1.0) -> void:
	if shadow_texture == null:
		return

	if tween != null:
		tween.kill()

	var fade_time := default_time

	if duration >= 0.0:
		fade_time = duration

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(shadow_texture, "modulate:a", alpha, fade_time)
