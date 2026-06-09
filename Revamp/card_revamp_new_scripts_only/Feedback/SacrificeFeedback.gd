extends Node
class_name SacrificeFeedback

@export var profile: SacrificeFeedbackProfile
var root: CardFeedbackRoot = null
var tween: Tween = null

func setup_feedback_root(source_root: CardFeedbackRoot) -> void:
	root = source_root

func play_idle() -> void:
	_play_shake(profile.idle_shake_distance, profile.idle_shake_time)

func play_selected() -> void:
	_play_shake(profile.selected_shake_distance, profile.selected_shake_time)

func play_committed() -> void:
	if root != null and root.scale_feedback != null and profile != null:
		root.scale_feedback.pulse(profile.committed_scale, profile.committed_time)

func stop() -> void:
	if tween != null:
		tween.kill()
		tween = null
	if root != null and root.shake_feedback != null:
		root.shake_feedback.stop()

func _play_shake(distance: float, time: float) -> void:
	if root == null or root.shake_feedback == null or profile == null:
		return
	stop()
	tween = create_tween()
	tween.tween_interval(randf_range(0.0, profile.random_start_delay_max))
	tween.tween_callback(func() -> void:
		root.shake_feedback.play(distance, time, 999)
	)
