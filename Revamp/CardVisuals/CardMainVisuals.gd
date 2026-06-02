extends Node2D
class_name CardMainVisuals

@export var ant_sprite: Sprite2D

@export var card_image: Sprite2D
@export var card_shadow: Sprite2D
@export var card_border: Sprite2D
@export var card_fog: Sprite2D


func set_ant_texture(texture: Texture2D) -> void:
	if ant_sprite == null:
		return

	if texture != null:
		ant_sprite.texture = texture


func set_background_texture(texture: Texture2D) -> void:
	if card_image == null:
		return

	if texture != null:
		card_image.texture = texture


func set_shadow_texture(texture: Texture2D) -> void:
	if card_shadow == null:
		return

	card_shadow.texture = texture
	card_shadow.visible = texture != null


func set_border_texture(texture: Texture2D) -> void:
	if card_border == null:
		return

	card_border.texture = texture
	card_border.visible = texture != null


func set_fog_visible(value: bool) -> void:
	if card_fog != null:
		card_fog.visible = value
