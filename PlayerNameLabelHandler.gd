extends Node
class_name PlayerNameLabelHandler

@export var player_name_label: Label
@export var enemy_name_label: Label

@export var fallback_player_one_name: String = "Player 1"
@export var fallback_player_two_name: String = "Player 2"

var turn_manager: TurnManager = null
var has_set_real_names := false


func _ready() -> void:
	_set_labels(fallback_player_one_name, fallback_player_two_name)

	if not GDSync.is_active():
		return

	await get_tree().process_frame
	await get_tree().process_frame

	turn_manager = get_tree().get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		return

	if not turn_manager.attacking_first_changed.is_connected(_on_turn_manager_ready):
		turn_manager.attacking_first_changed.connect(_on_turn_manager_ready)

	_try_set_names()


func _on_turn_manager_ready(_client_id: int) -> void:
	_try_set_names()


func _try_set_names() -> void:
	if has_set_real_names:
		return

	if turn_manager == null:
		return

	var player_one_id := turn_manager.player_one_id
	var player_two_id := turn_manager.player_two_id

	if player_one_id == -1 or player_two_id == -1:
		return

	var player_one_name := GDSync.player_get_username(
		player_one_id,
		fallback_player_one_name
	)

	var player_two_name := GDSync.player_get_username(
		player_two_id,
		fallback_player_two_name
	)

	_set_labels(player_one_name, player_two_name)

	has_set_real_names = true


func _set_labels(player_one_name: String, player_two_name: String) -> void:
	if player_name_label != null:
		player_name_label.text = player_one_name

	if enemy_name_label != null:
		enemy_name_label.text = player_two_name
