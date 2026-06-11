extends Node
class_name LobbyJoinHandler

signal join_started(lobby_name: String)
signal join_succeeded(lobby_name: String)
signal join_failed(lobby_name: String, error: int)

var pending_lobby_name := ""


func _ready() -> void:
	randomize()

	if not GDSync.lobby_joined.is_connected(_on_lobby_joined):
		GDSync.lobby_joined.connect(_on_lobby_joined)

	if not GDSync.lobby_join_failed.is_connected(_on_lobby_join_failed):
		GDSync.lobby_join_failed.connect(_on_lobby_join_failed)


func join_public_lobby(lobby_info: Dictionary) -> void:
	var lobby_name: String = lobby_info.get("lobby_name", "")

	if lobby_name == "":
		join_failed.emit("", -1)
		return

	pending_lobby_name = lobby_name
	join_started.emit(lobby_name)

	GDSync.lobby_join(lobby_name, "")


func join_private_lobby(lobby_info: Dictionary, passcode: String) -> void:
	var lobby_name: String = lobby_info.get("lobby_name", "")

	if lobby_name == "":
		join_failed.emit("", -1)
		return

	pending_lobby_name = lobby_name
	join_started.emit(lobby_name)

	GDSync.lobby_join(lobby_name, passcode)


func join_random_lobby(lobbies: Array) -> void:
	var public_lobbies := []

	for lobby_info in lobbies:
		if lobby_info.get("is_private", false):
			continue

		if not lobby_info.get("is_open", false):
			continue

		if lobby_info.get("player_count", 0) >= lobby_info.get("player_limit", 2):
			continue

		public_lobbies.append(lobby_info)

	if public_lobbies.is_empty():
		join_failed.emit("", -2)
		return

	join_public_lobby(public_lobbies.pick_random())


func _on_lobby_joined(lobby_name: String) -> void:
	if pending_lobby_name == "":
		return

	if lobby_name != pending_lobby_name:
		return

	pending_lobby_name = ""
	join_succeeded.emit(lobby_name)


func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	if pending_lobby_name == "":
		return

	if lobby_name != pending_lobby_name:
		return

	pending_lobby_name = ""
	join_failed.emit(lobby_name, error)
