extends Node
class_name SlotAttackPreviewFeedback

@export var shader_rect: CanvasItem
@export var icon_sprite: CanvasItem

var slot_feedback: SlotFeedback = null
var is_previewed: bool = false


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	set_previewed(false)


func set_previewed(value: bool) -> void:
	if is_previewed == value:
		return

	is_previewed = value

	if shader_rect != null:
		shader_rect.visible = value

	if icon_sprite != null:
		icon_sprite.visible = value
