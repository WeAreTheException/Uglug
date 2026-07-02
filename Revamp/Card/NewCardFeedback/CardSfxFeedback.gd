extends Node
class_name CardSfxFeedback

@export_group("Audio Players")
@export var hurt_audio_player: AudioStreamPlayer
@export var hurt_audio_player_2d: AudioStreamPlayer2D

@export_group("Hurt SFX")
@export var hurt_sound: AudioStream
@export var hurt_volume_db: float = 0.0
@export var hurt_pitch_min: float = 0.96
@export var hurt_pitch_max: float = 1.04

@export var print_debug: bool = true


func play_hurt_sfx() -> void:
	var player := _get_hurt_player()

	if player == null:
		_debug_print("Missing hurt audio player.")
		return

	if hurt_sound == null:
		_debug_print("Missing hurt_sound.")
		return

	player.stream = hurt_sound
	player.volume_db = hurt_volume_db
	player.pitch_scale = randf_range(hurt_pitch_min, hurt_pitch_max)
	player.stop()
	player.play()


func _get_hurt_player() -> Node:
	if hurt_audio_player != null:
		return hurt_audio_player

	if hurt_audio_player_2d != null:
		return hurt_audio_player_2d

	return null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardSfxFeedback] ", message)
