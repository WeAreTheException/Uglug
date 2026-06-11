extends Node
class_name LobbyHostHandler

signal lobby_create_started
signal lobby_create_succeeded(lobby_name: String)
signal lobby_create_failed(lobby_name: String, error: int)
signal lobby_join_succeeded(lobby_name: String, lobby_info: Dictionary)
signal lobby_join_failed(lobby_name: String, error: int)

@export var force_creation_failure := false

var pending_password := ""
var pending_lobby_name := ""
var pending_lobby_info: Dictionary = {}


func _ready() -> void:
	randomize()

	GDSync.lobby_created.connect(_on_lobby_created)
	GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)
	GDSync.lobby_joined.connect(_on_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_lobby_join_failed)


func create_lobby(is_private: bool, passcode: String, spawn_id: int) -> void:
	var lobby_name := _build_lobby_name()
	pending_lobby_name = lobby_name
	pending_password = passcode if is_private else ""

	pending_lobby_info = {
		"lobby_name": lobby_name,
		"player_count": 1,
		"player_limit": 2,
		"is_open": true,
		"is_public": true,
		"display_name": _get_display_name(),
		"is_private": is_private,
		"has_password": is_private,
		"spawn_id": spawn_id
	}

	lobby_create_started.emit()

	if force_creation_failure:
		await get_tree().create_timer(0.5).timeout
		lobby_create_failed.emit(lobby_name, -999)
		return

	var tags := {
		"display_name": _get_display_name(),
		"spawn_id": spawn_id
	}

	GDSync.lobby_create(lobby_name, pending_password, true, 2, tags)


func _on_lobby_created(lobby_name: String) -> void:
	if lobby_name != pending_lobby_name:
		return

	lobby_create_succeeded.emit(lobby_name)
	GDSync.lobby_join(lobby_name, pending_password)


func _on_lobby_creation_failed(lobby_name: String, error: int) -> void:
	if lobby_name != pending_lobby_name:
		return

	pending_lobby_name = ""
	pending_lobby_info = {}
	lobby_create_failed.emit(lobby_name, error)


func _on_lobby_joined(lobby_name: String) -> void:
	if lobby_name != pending_lobby_name:
		return

	lobby_join_succeeded.emit(lobby_name, pending_lobby_info)


func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	if lobby_name != pending_lobby_name:
		return

	pending_lobby_name = ""
	pending_lobby_info = {}
	lobby_join_failed.emit(lobby_name, error)


func _build_lobby_name() -> String:
	return "Uglug" + str(GDSync.get_client_id()) + str(randi_range(1000, 9999))


func _get_display_name() -> String:
	return GDSync.player_get_username(GDSync.get_client_id(), "Player" + str(GDSync.get_client_id()))
