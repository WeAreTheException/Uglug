extends Node
class_name AttackAudio

@export var attack_sfx: AudioStream
@export var volume_db: float = 0.0
@export var sfx_bus_name: String = "SFX"

var audio_player: AudioStreamPlayer


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

	audio_player.volume_db = volume_db
	audio_player.bus = sfx_bus_name


func play() -> void:
	if attack_sfx == null:
		return

	audio_player.stream = attack_sfx
	audio_player.play()
