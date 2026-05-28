extends Node
class_name ViewportDisplayController

@export var sub_viewport: SubViewport
@export var viewport_sprite: Sprite2D


func _ready() -> void:
	if sub_viewport == null:
		return

	if viewport_sprite == null:
		return

	sub_viewport.transparent_bg = true
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	viewport_sprite.texture = sub_viewport.get_texture()
