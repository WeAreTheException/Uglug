extends Node
class_name CardSelectFeedback

@export var profile: SelectFeedbackProfile
var root: CardFeedbackRoot = null
var is_selected := false

func setup_feedback_root(source_root: CardFeedbackRoot) -> void:
	root = source_root

func play(value: bool) -> void:
	is_selected = value
	if profile == null or root == null:
		return
	if profile.scale_enabled and root.scale_feedback != null:
		var scale := profile.selected_scale if value else root.scale_feedback.base_scale
		root.scale_feedback.tween_to(scale, profile.scale_time)
	if profile.position_enabled and root.position_feedback != null:
		if value:
			root.position_feedback.tween_offset(profile.selected_offset, profile.position_time)
		else:
			root.position_feedback.reset(profile.position_time)
	if profile.shadow_enabled and root.shadow_feedback != null:
		root.shadow_feedback.fade_visible(value)
