extends Node

@export var player_name_label: Label
@export var enemy_name_label: Label

func _ready() -> void:
	if not GDSync.is_active():
		if player_name_label != null:
			player_name_label.text = "Local Player"
		if enemy_name_label != null:
			enemy_name_label.text = "Enemy"
		return

	await get_tree().create_timer(1.0).timeout

	var my_id := GDSync.get_client_id()
	var my_name := GDSync.player_get_username(my_id, "Me")

	var enemy_id := -1
	var clients := GDSync.lobby_get_all_clients()

	for id in clients:
		if id != my_id:
			enemy_id = id
			break

	var enemy_name := "Enemy"
	if enemy_id != -1:
		enemy_name = GDSync.player_get_username(enemy_id, "Enemy")

	if player_name_label != null:
		player_name_label.text = my_name

	if enemy_name_label != null:
		enemy_name_label.text = enemy_name
