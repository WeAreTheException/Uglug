extends Node
class_name PlayerNameLabelHandler

@export var player_name_label: Label
@export var enemy_name_label: Label

@export var fallback_player_one_name: String = "Player 1"
@export var fallback_player_two_name: String = "Player 2"


func _ready() -> void:
	if not GDSync.is_active():
		_set_labels(fallback_player_one_name, fallback_player_two_name)
		return

	await get_tree().create_timer(1.0).timeout

	var turn_manager := get_tree().get_first_node_in_group("turn_manager") as TurnManager

	var player_one_id := -1
	var player_two_id := -1

	if turn_manager != null:
		player_one_id = turn_manager.player_one_id
		player_two_id = turn_manager.player_two_id

	if player_one_id == -1 or player_two_id == -1:
		return

	var local_id := int(GDSync.get_client_id())

	var local_player_name := ""
	var enemy_player_name := ""

	if local_id == player_one_id:
		local_player_name = GDSync.player_get_username(player_one_id, fallback_player_one_name)
		enemy_player_name = GDSync.player_get_username(player_two_id, fallback_player_two_name)
	else:
		local_player_name = GDSync.player_get_username(player_two_id, fallback_player_two_name)
		enemy_player_name = GDSync.player_get_username(player_one_id, fallback_player_one_name)

	_set_labels(local_player_name, enemy_player_name)


func _set_labels(local_player_name: String, enemy_player_name: String) -> void:
	if player_name_label != null:
		player_name_label.text = local_player_name

	if enemy_name_label != null:
		enemy_name_label.text = enemy_player_name
