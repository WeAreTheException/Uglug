extends Node
class_name CardMainVisuals

@export var ant_sprite: Sprite2D
@export var background_sprite: Sprite2D
@export var name_label: Label

func setup_from_data(data: CardData) -> void:
	if data == null:
		return
	set_ant_texture(data.ant_texture)
	set_background_texture(data.background_texture)
	set_card_name(data.name)

func set_ant_texture(texture: Texture2D) -> void:
	if ant_sprite != null:
		ant_sprite.texture = texture

func set_background_texture(texture: Texture2D) -> void:
	if background_sprite != null:
		background_sprite.texture = texture

func set_card_name(value: String) -> void:
	if name_label != null:
		name_label.text = value
