extends Node2D
class_name Hand_EvolutionFeedback

@export var animation_runner: EvolutionAnimationRunner
@export var particles: GPUParticles2D
@export var audio_player: AudioStreamPlayer

@export var spacing_bonus: float = 55.0
@export var particle_offset: Vector2 = Vector2(0.0, -20.0)


func play(
	cards: Array[CardRoot],
	evolved_card: CardRoot,
	rest_positions: Array[Vector2],
	spread_positions: Array[Vector2],
	rest_scale: Vector2,
	z_value: int
) -> void:
	if evolved_card == null:
		return

	if not is_instance_valid(evolved_card):
		return

	global_position = evolved_card.global_position + particle_offset

	_play_particles()
	_play_audio()

	if animation_runner != null:
		animation_runner.play(
			cards,
			evolved_card,
			rest_positions,
			spread_positions,
			rest_scale,
			z_value
		)


func cancel() -> void:
	if animation_runner != null:
		animation_runner.cancel()

	if particles != null:
		particles.emitting = false


func is_playing() -> bool:
	if animation_runner == null:
		return false

	return animation_runner.is_playing()


func get_spacing_bonus() -> float:
	return spacing_bonus


func _play_particles() -> void:
	if particles == null:
		return

	particles.position = Vector2.ZERO
	particles.restart()
	particles.emitting = true


func _play_audio() -> void:
	if audio_player == null:
		return

	audio_player.stop()
	audio_player.play()
