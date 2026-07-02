extends Sprite2D

@export var test_key: Key = KEY_H

@export var start_scale: Vector2 = Vector2(1.4, 1.4)
@export var end_scale: Vector2 = Vector2(1.9, 1.9)

@export var start_alpha: float = 1.0
@export var end_alpha: float = 0.0

@export var pop_time: float = 0.05
@export var fade_time: float = 0.18

var original_scale: Vector2
var original_alpha: float
var punch_tween: Tween = null


func _ready() -> void:
	original_scale = scale
	original_alpha = modulate.a
	visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey

		if key_event.pressed and not key_event.echo and key_event.keycode == test_key:
			play_punch()


func play_punch() -> void:
	if punch_tween != null:
		punch_tween.kill()

	visible = true
	scale = start_scale
	modulate.a = start_alpha

	punch_tween = create_tween()
	punch_tween.set_parallel(true)

	punch_tween.tween_property(self, "scale", end_scale, fade_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	punch_tween.tween_property(self, "modulate:a", end_alpha, fade_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	punch_tween.set_parallel(false)
	punch_tween.tween_callback(_finish_punch)


func _finish_punch() -> void:
	visible = false
	scale = original_scale
	modulate.a = original_alpha
