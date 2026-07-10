extends Node
class_name CardHoverFeedback

@export var target: Node2D

var is_enabled: bool = true


func set_enabled(value: bool, reset_when_disabled: bool = true) -> void:
	is_enabled = value


func play_hover() -> void:
	if not is_enabled:
		return


func play_unhover() -> void:
	pass
