extends Node
class_name CardSfxFeedback

@export_group("Audio Players")
@export var hurt_audio_player: AudioStreamPlayer
@export var hurt_audio_player_2d: AudioStreamPlayer2D

@export var print_debug: bool = true


func play_hurt_sfx(profile: CardFeedbackProfile) -> void:
	if profile == null:
		_debug_print("Missing profile.")
		return

	var player := _get_hurt_player()

	if player == null:
		_debug_print("Missing hurt audio player.")
		return

	if profile.hurt_sound == null:
		_debug_print("Missing hurt_sound in profile.")
		return

	player.stream = profile.hurt_sound
	player.volume_db = profile.hurt_volume_db
	player.pitch_scale = randf_range(profile.hurt_pitch_min, profile.hurt_pitch_max)
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
