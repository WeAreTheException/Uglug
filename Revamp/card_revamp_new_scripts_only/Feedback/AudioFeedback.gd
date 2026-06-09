extends Node
class_name AudioFeedback

@export var player: AudioStreamPlayer

func setup_feedback_root(_root: CardFeedbackRoot) -> void:
	pass

func play_stream(stream: AudioStream) -> void:
	if player == null or stream == null:
		return
	player.stream = stream
	player.play()
