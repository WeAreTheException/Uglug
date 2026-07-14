extends Node
class_name SlotPlayPhaseFeedback

@export var normal_sprite: CanvasItem
@export var playable_shader_sprite: CanvasItem

var slot_feedback: SlotFeedback = null
var is_playable: bool = false


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	show_idle()


func show_idle() -> void:
	set_playable(false)


func show_playable() -> void:
	set_playable(true)


func show_inactive() -> void:
	set_playable(false)


func set_playable(value: bool) -> void:
	is_playable = value

	if normal_sprite != null:
		normal_sprite.visible = not value

	if playable_shader_sprite != null:
		playable_shader_sprite.visible = value
