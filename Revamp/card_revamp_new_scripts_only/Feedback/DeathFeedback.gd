extends Node
class_name DeathFeedback

@export var profile: DeathFeedbackProfile
var root: CardFeedbackRoot = null

func setup_feedback_root(source_root: CardFeedbackRoot) -> void:
	root = source_root

func play(_context: DeathContext) -> void:
	if profile == null or root == null:
		return
	if profile.audio_enabled and root.audio_feedback != null:
		root.audio_feedback.play_stream(profile.audio_stream)
	if profile.shake_enabled and root.shake_feedback != null:
		await root.shake_feedback.play(
			profile.shake_distance,
			profile.shake_time,
			profile.shake_count
		)
	if profile.scale_enabled and root.scale_feedback != null:
		await root.scale_feedback.tween_to(profile.death_scale, profile.scale_time)
