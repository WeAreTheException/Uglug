extends Node2D
class_name CardArt

@export var ant_sprite: Sprite2D

@export var card_image: Sprite2D
@export var card_shadow: Sprite2D
@export var card_border: Sprite2D

@export var base_sigil_container: Node2D
@export var additional_sigil_container: Node2D

@export var card_fog: Sprite2D
@export var background_dots: Sprite2D


func set_ant_texture(texture: Texture2D) -> void:
	if ant_sprite == null:
		return

	ant_sprite.texture = texture
	ant_sprite.visible = texture != null


func set_card_texture(texture: Texture2D) -> void:
	if card_image == null:
		return

	card_image.texture = texture
	card_image.visible = texture != null


func set_base_sigil(index: int, texture: Texture2D) -> void:
	_set_sigil_texture(base_sigil_container, index, texture)


func set_additional_sigil(index: int, texture: Texture2D) -> void:
	_set_sigil_texture(additional_sigil_container, index, texture)


func clear_base_sigils() -> void:
	_clear_sigils(base_sigil_container)


func clear_additional_sigils() -> void:
	_clear_sigils(additional_sigil_container)


func _set_sigil_texture(container: Node2D, index: int, texture: Texture2D) -> void:
	if container == null:
		return

	if index < 0:
		return

	if index >= container.get_child_count():
		return

	var child := container.get_child(index)

	if child is Sprite2D:
		child.texture = texture
		child.visible = texture != null


func _clear_sigils(container: Node2D) -> void:
	if container == null:
		return

	for child in container.get_children():
		if child is Sprite2D:
			child.texture = null
			child.visible = false
