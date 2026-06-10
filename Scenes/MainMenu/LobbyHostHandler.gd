extends Node
class_name LobbyHostHandler

signal lobby_create_started
signal lobby_create_succeeded(lobby_name: String)
signal lobby_create_failed(lobby_name: String, error: int)
signal lobby_join_succeeded(lobby_name: String)
signal lobby_join_failed(lobby_name: String, error: int)

@export var force_creation_failure := false

var pending_password := ""


func _ready() -> void:
	if not GDSync.lobby_created.is_connected(_on_lobby_created):
		GDSync.lobby_created.connect(_on_lobby_created)

	if not GDSync.lobby_creation_failed.is_connected(_on_lobby_creation_failed):
		GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)

	if not GDSync.lobby_joined.is_connected(_on_lobby_joined):
		GDSync.lobby_joined.connect(_on_lobby_joined)

	if not GDSync.lobby_join_failed.is_connected(_on_lobby_join_failed):
		GDSync.lobby_join_failed.connect(_on_lobby_join_failed)


func create_lobby(is_private: bool, passcode: String) -> void:
	var lobby_name := _build_lobby_name()
	pending_password = passcode if is_private else ""

	lobby_create_started.emit()

	if force_creation_failure:
		await get_tree().create_timer(0.5).timeout
		lobby_create_failed.emit(lobby_name, -999)
		return

	var tags := {
		"display_name": _get_display_name(),
		"is_private": is_private,
		"spawn_id": 0
	}

	GDSync.lobby_create(
		lobby_name,
		pending_password,
		true,
		2,
		tags
	)


func _on_lobby_created(lobby_name: String) -> void:
	lobby_create_succeeded.emit(lobby_name)
	GDSync.lobby_join(lobby_name, pending_password)


func _on_lobby_creation_failed(lobby_name: String, error: int) -> void:
	lobby_create_failed.emit(lobby_name, error)


func _on_lobby_joined(lobby_name: String) -> void:
	lobby_join_succeeded.emit(lobby_name)


func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	lobby_join_failed.emit(lobby_name, error)


func _build_lobby_name() -> String:
	var id := str(Time.get_unix_time_from_system()).right(6)
	return "Uglug_" + str(GDSync.get_client_id()) + "_" + id


func _get_display_name() -> String:
	return "Player" + str(GDSync.get_client_id())
