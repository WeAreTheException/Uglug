extends Camera2D
class_name ScreenshakeBrain

var _is_shaking := false
var _original_offset := Vector2.ZERO


func _ready() -> void:
	_original_offset = offset


func shake(
	delay_before_shake: float = 0.20,
	shake_time: float = 0.12,
	shake_strength: float = 8.0,
	shake_steps: int = 6
) -> void:

	if _is_shaking:
		return

	_is_shaking = true

	if delay_before_shake > 0.0:
		await get_tree().create_timer(delay_before_shake).timeout

	_original_offset = offset

	var tween := create_tween()

	var step_time := shake_time / float(max(shake_steps, 1))

	for i in range(shake_steps):
		var random_offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		tween.tween_property(
			self,
			"offset",
			_original_offset + random_offset,
			step_time
		)

	tween.tween_property(
		self,
		"offset",
		_original_offset,
		step_time
	)

	await tween.finished

	offset = _original_offset
	_is_shaking = false
