extends Node
class_name MultiplayerConnectionHandler

signal connection_started
signal connection_succeeded
signal connection_failed(error: int)

@export var steam_identity: SteamPlayerIdentity

@export var force_connection_failure := false
@export var print_connection_debug := false

var is_connected_to_gdsync := false
var is_connecting := false


func _ready() -> void:
	randomize()


func start_connection() -> void:
	if is_connected_to_gdsync or is_connecting:
		return

	is_connecting = true
	connection_started.emit()

	if force_connection_failure:
		await get_tree().create_timer(0.5).timeout
		_on_connection_failed(-999)
		return

	if not GDSync.connected.is_connected(_on_connected):
		GDSync.connected.connect(_on_connected)

	if not GDSync.connection_failed.is_connected(_on_connection_failed):
		GDSync.connection_failed.connect(_on_connection_failed)

	GDSync.start_multiplayer()


func _on_connected() -> void:
	is_connecting = false
	is_connected_to_gdsync = true

	var username := _build_username()
	GDSync.player_set_username(username)

	if print_connection_debug:
		print("GD-Sync connected.")
		print("Client ID: ", GDSync.get_client_id())
		print("Username set to: ", username)

	connection_succeeded.emit()


func _on_connection_failed(error: int) -> void:
	is_connecting = false
	is_connected_to_gdsync = false

	if print_connection_debug:
		print("GD-Sync connection failed: ", error)

	connection_failed.emit(error)


func _build_username() -> String:
	var client_id := _get_client_id_as_int()

	if steam_identity != null:
		return steam_identity.get_display_name_for_id(client_id)

	return PlaceholderPlayerNames.get_name_for_id(client_id)


func _get_client_id_as_int() -> int:
	var raw_client_id := str(GDSync.get_client_id())

	if raw_client_id.is_valid_int():
		return raw_client_id.to_int()

	return abs(raw_client_id.hash())
