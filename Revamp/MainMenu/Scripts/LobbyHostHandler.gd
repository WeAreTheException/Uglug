extends Node
class_name LobbyHostHandler

signal lobby_create_started
signal lobby_create_succeeded(lobby_name: String)
signal lobby_create_failed(lobby_name: String, error: int)
signal lobby_join_succeeded(lobby_name: String, lobby_info: Dictionary)
signal lobby_join_failed(lobby_name: String, error: int)

@export var force_creation_failure := false
@export var steam_identity: SteamPlayerIdentity

var pending_password := ""
var pending_lobby_name := ""
var pending_lobby_info: Dictionary = {}


func _ready() -> void:
	randomize()

	if not GDSync.lobby_created.is_connected(_on_lobby_created):
		GDSync.lobby_created.connect(_on_lobby_created)

	if not GDSync.lobby_creation_failed.is_connected(_on_lobby_creation_failed):
		GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)

	if not GDSync.lobby_joined.is_connected(_on_lobby_joined):
		GDSync.lobby_joined.connect(_on_lobby_joined)

	if not GDSync.lobby_join_failed.is_connected(_on_lobby_join_failed):
		GDSync.lobby_join_failed.connect(_on_lobby_join_failed)


func create_lobby(is_private: bool, passcode: String, spawn_id: int) -> void:
	var lobby_name := _build_lobby_name()
	var display_name := _get_display_name()

	pending_lobby_name = lobby_name
	pending_password = passcode if is_private else ""

	pending_lobby_info = {
		"lobby_name": lobby_name,
		"player_count": 1,
		"player_limit": 2,
		"is_open": true,
		"is_public": true,
		"display_name": display_name,
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
		"display_name": display_name,
		"spawn_id": spawn_id
	}

	GDSync.lobby_create(
		lobby_name,
		pending_password,
		true,
		2,
		tags
	)


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
	var client_id := str(GDSync.get_client_id())
	var random_id := str(randi_range(1000, 9999))

	return "Uglug" + client_id + random_id


func _get_display_name() -> String:
	var fallback_name := GDSync.player_get_username(
		GDSync.get_client_id(),
		"Player" + str(GDSync.get_client_id())
	)

	if steam_identity == null:
		return fallback_name

	return steam_identity.get_display_name(fallback_name)
