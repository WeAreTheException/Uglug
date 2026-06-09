extends Node
class_name HurtFeedback

@export var profile: HurtFeedbackProfile
var root: CardFeedbackRoot = null

func setup_feedback_root(source_root: CardFeedbackRoot) -> void:
	root = source_root

func play(_context: DamageContext) -> void:
	if profile == null or root == null:
		return
	if profile.audio_enabled and root.audio_feedback != null:
		root.audio_feedback.play_stream(profile.audio_stream)
	if profile.flash_enabled and root.flash_feedback != null:
		root.flash_feedback.play(profile.flash_time)
	if profile.scale_enabled and root.scale_feedback != null:
		root.scale_feedback.pulse(profile.hit_scale, profile.scale_time)
	if profile.shake_enabled and root.shake_feedback != null:
		await root.shake_feedback.play(
			profile.shake_distance,
			profile.shake_time,
			profile.shake_count
		)
