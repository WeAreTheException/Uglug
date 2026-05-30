extends Node
class_name SacrificeSprite

@export var sacrifice_texture: Texture2D

@export var hovered_color: Color = Color.WHITE
@export var selected_color: Color = Color.BLACK

@export var sprite_offset: Vector2 = Vector2.ZERO
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_z_index: int = 100

var active_sprite: Sprite2D = null


func show_hovered(card: Card) -> void:
	_show_sprite(card, hovered_color)


func show_selected(card: Card) -> void:
	_show_sprite(card, selected_color)


func hide_sprite() -> void:
	if is_instance_valid(active_sprite):
		active_sprite.visible = false


func _show_sprite(card: Card, color: Color) -> void:
	if card == null:
		return

	if not is_instance_valid(active_sprite):
		active_sprite = Sprite2D.new()
		card.add_child(active_sprite)

	active_sprite.centered = true
	active_sprite.position = sprite_offset
	active_sprite.scale = sprite_scale
	active_sprite.z_index = sprite_z_index
	active_sprite.visible = true
	active_sprite.modulate = color

	if sacrifice_texture != null:
		active_sprite.texture = sacrifice_texture
