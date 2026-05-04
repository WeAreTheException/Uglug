extends Node

@export var player_name_label: Label
@export var enemy_name_label: Label

func _ready() -> void:
	print("entered multiplayer scene")

	# 🔥 wait for GD-Sync username sync
	await get_tree().create_timer(1.0).timeout

	var my_id := GDSync.get_client_id()

	var my_name := GDSync.player_get_username(my_id, "Me")

	# find enemy (other client)
	var enemy_id := -1
	var clients := GDSync.lobby_get_all_clients()

	for id in clients:
		if id != my_id:
			enemy_id = id
			break

	var enemy_name := "Enemy"
	if enemy_id != -1:
		enemy_name = GDSync.player_get_username(enemy_id, "Enemy")

	# assign labels
	player_name_label.text = my_name
	enemy_name_label.text = enemy_name

	print("Player name: ", my_name)
	print("Enemy name: ", enemy_name)
