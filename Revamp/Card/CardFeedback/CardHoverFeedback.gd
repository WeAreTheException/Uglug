extends Node
class_name CardHoverFeedback

@export var target: Node2D
@export var hover_audio: AudioStreamPlayer

var is_enabled: bool = true

static var current_hover_audio: AudioStreamPlayer = null


func set_enabled(value: bool, reset_when_disabled: bool = true) -> void:
	is_enabled = value


func play_hover() -> void:
	if not is_enabled:
		return

	if hover_audio == null:
		return

	if is_instance_valid(current_hover_audio):
		if current_hover_audio.playing:
			return

	current_hover_audio = hover_audio
	hover_audio.play()


func play_unhover() -> void:
	pass
