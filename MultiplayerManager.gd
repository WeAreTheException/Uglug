extends Node

@export var player_name_label: Label
@export var enemy_name_label: Label


func _ready() -> void:
	if not GDSync.is_active():
		if player_name_label != null:
			player_name_label.text = "Player 1"

		if enemy_name_label != null:
			enemy_name_label.text = "Player 2"

		return

	await get_tree().create_timer(1.0).timeout

	var turn_manager := get_tree().get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		print("name label blocked: turn_manager missing")
		return

	var player_one_id := turn_manager.player_one_id
	var player_two_id := turn_manager.player_two_id

	var player_one_name := GDSync.player_get_username(player_one_id, "Player 1")
	var player_two_name := GDSync.player_get_username(player_two_id, "Player 2")

	if player_name_label != null:
		player_name_label.text = player_one_name

	if enemy_name_label != null:
		enemy_name_label.text = player_two_name
