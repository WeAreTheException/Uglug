extends Node
class_name AttackScreenShake

@export var delay_before_shake: float = 0.20
@export var shake_time: float = 0.12
@export var shake_strength: float = 8.0
@export var shake_steps: int = 6

var camera: Camera2D = null
var original_offset: Vector2 = Vector2.ZERO
var is_playing: bool = false


func play() -> void:
	if is_playing:
		return

	camera = get_viewport().get_camera_2d()

	if camera == null:
		print("screen shake blocked: no active Camera2D found")
		return

	is_playing = true

	await get_tree().create_timer(delay_before_shake).timeout

	original_offset = camera.offset

	var tween := create_tween()
	var step_time := shake_time / float(max(shake_steps, 1))

	for i in shake_steps:
		var random_offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		tween.tween_property(camera, "offset", original_offset + random_offset, step_time)

	tween.tween_property(camera, "offset", original_offset, step_time)

	await tween.finished

	if is_instance_valid(camera):
		camera.offset = original_offset

	is_playing = false
