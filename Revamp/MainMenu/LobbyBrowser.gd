extends Node
class_name LobbyBrowser

signal browse_started
signal lobbies_updated(lobbies: Array)

@export var refresh_seconds := 3.0

var is_browsing := false
var refresh_timer: Timer


func _ready() -> void:
	if not GDSync.lobbies_received.is_connected(_on_lobbies_received):
		GDSync.lobbies_received.connect(_on_lobbies_received)

	refresh_timer = Timer.new()
	refresh_timer.wait_time = refresh_seconds
	refresh_timer.autostart = false
	refresh_timer.timeout.connect(request_lobbies)
	add_child(refresh_timer)


func start_browsing() -> void:
	is_browsing = true

	if refresh_timer == null:
		return

	if refresh_timer.is_stopped():
		refresh_timer.start()

	request_lobbies()


func stop_browsing() -> void:
	is_browsing = false

	if refresh_timer != null:
		refresh_timer.stop()


func request_lobbies() -> void:
	if not is_browsing:
		return

	browse_started.emit()
	GDSync.get_public_lobbies()


func _on_lobbies_received(raw_lobbies: Array) -> void:
	var converted_lobbies := []

	for raw_lobby in raw_lobbies:
		if not raw_lobby is Dictionary:
			continue

		if not _is_joinable_lobby(raw_lobby):
			continue

		converted_lobbies.append(_convert_lobby(raw_lobby))

	lobbies_updated.emit(converted_lobbies)


func _is_joinable_lobby(raw_lobby: Dictionary) -> bool:
	var is_open: bool = raw_lobby.get("Open", false)

	if not is_open:
		return false

	return true


func _convert_lobby(raw_lobby: Dictionary) -> Dictionary:
	var tags: Dictionary = raw_lobby.get("Tags", {})
	var has_password: bool = raw_lobby.get("HasPassword", false)

	return {
		"lobby_name": raw_lobby.get("Name", ""),
		"player_count": raw_lobby.get("PlayerCount", 0),
		"player_limit": raw_lobby.get("PlayerLimit", 2),
		"is_open": raw_lobby.get("Open", false),
		"is_public": raw_lobby.get("Public", true),
		"display_name": tags.get("display_name", "Unknown Player"),
		"is_private": has_password,
		"has_password": has_password,
		"spawn_id": tags.get("spawn_id", 0)
	}
