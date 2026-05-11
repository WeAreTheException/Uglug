extends Node
class_name AttackOrderSpriteHandler

@export var turn_manager: TurnManager
@export var player_one_sprite: Sprite2D
@export var player_two_sprite: Sprite2D

func _ready() -> void:
	if player_one_sprite != null:
		player_one_sprite.visible = false

	if player_two_sprite != null:
		player_two_sprite.visible = false

	if turn_manager != null:
		if not turn_manager.attacking_first_changed.is_connected(_on_attacking_first_changed):
			turn_manager.attacking_first_changed.connect(_on_attacking_first_changed)

func _on_attacking_first_changed(first_player_id: int) -> void:
	var my_id := GDSync.get_client_id()

	if player_one_sprite != null:
		player_one_sprite.visible = my_id == first_player_id

	if player_two_sprite != null:
		player_two_sprite.visible = my_id != first_player_id
