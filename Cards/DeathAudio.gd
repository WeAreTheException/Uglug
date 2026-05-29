extends Node
class_name DeathAudio

@export var death_sfx: AudioStream
@export var volume_db: float = 0.0
@export var sfx_bus_name: String = "SFX"


func play_detached() -> void:
	if death_sfx == null:
		return

	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = death_sfx
	audio_player.volume_db = volume_db
	audio_player.bus = sfx_bus_name

	get_tree().current_scene.add_child(audio_player)

	audio_player.play()

	await audio_player.finished

	if is_instance_valid(audio_player):
		audio_player.queue_free()
