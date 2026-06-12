extends Node
class_name MatchStartHandler

signal match_start_requested
signal match_start_failed(reason: String)

@export_file("*.tscn") var game_scene_path := ""

var has_started_match := false


func _ready() -> void:
	if not GDSync.client_joined.is_connected(_on_client_joined):
		GDSync.client_joined.connect(_on_client_joined)

	if not GDSync.change_scene_failed.is_connected(_on_change_scene_failed):
		GDSync.change_scene_failed.connect(_on_change_scene_failed)


func reset() -> void:
	has_started_match = false


func _on_client_joined(_client_id: int) -> void:
	if has_started_match:
		return

	if not GDSync.is_host():
		return

	var clients: Array = GDSync.lobby_get_all_clients()

	if clients.size() < 2:
		return

	_start_match()


func _start_match() -> void:
	if game_scene_path == "":
		match_start_failed.emit("Game scene path is empty.")
		return

	has_started_match = true
	match_start_requested.emit()

	print("Starting match: ", game_scene_path)
	GDSync.lobby_set_tag("state", "in_game")
	GDSync.lobby_set_tag("joinable", false)
	GDSync.change_scene(game_scene_path)


func _on_change_scene_failed(scene_path: String) -> void:
	has_started_match = false
	match_start_failed.emit("Failed to change scene: " + scene_path)
