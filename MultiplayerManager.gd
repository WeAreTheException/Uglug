extends Node

@export var player_name_label: Label
@export var enemy_name_label: Label


func _ready() -> void:
	if not GDSync.is_active():
		_set_labels("Player 1", "Player 2")
		return

	await get_tree().create_timer(1.0).timeout

	var player_one_id := -1
	var player_two_id := -1

	var turn_manager := get_tree().get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager != null:
		player_one_id = turn_manager.player_one_id
		player_two_id = turn_manager.player_two_id

	if player_one_id == -1 or player_two_id == -1:
		var clients := GDSync.lobby_get_all_clients()

		if clients.size() >= 2:
			player_one_id = int(clients[0])
			player_two_id = int(clients[1])

	var player_one_name := GDSync.player_get_username(player_one_id, "Player 1")
	var player_two_name := GDSync.player_get_username(player_two_id, "Player 2")

	_set_labels(player_one_name, player_two_name)


func _set_labels(player_one_name: String, player_two_name: String) -> void:
	if player_name_label != null:
		player_name_label.text = player_one_name

	if enemy_name_label != null:
		enemy_name_label.text = player_two_name
