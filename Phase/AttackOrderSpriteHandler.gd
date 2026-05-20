extends Node
class_name AttackOrderSpriteHandler

@export var player_one_sprite: Sprite2D
@export var player_two_sprite: Sprite2D


func _ready() -> void:
	var my_id := GDSync.get_client_id()
	var host_id := GDSync.get_host()

	var am_host := my_id == host_id

	if player_one_sprite != null:
		player_one_sprite.visible = am_host

	if player_two_sprite != null:
		player_two_sprite.visible = not am_host
