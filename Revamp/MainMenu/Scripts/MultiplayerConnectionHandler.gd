extends Node
class_name MultiplayerConnectionHandler

signal connection_started
signal connection_succeeded
signal connection_failed(error: int)

@export var force_connection_failure := false

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

	var username := _build_unique_username()
	GDSync.player_set_username(username)

	print("GD-Sync connected.")
	print("Client ID: ", GDSync.get_client_id())
	print("Username set to: ", username)

	connection_succeeded.emit()


func _on_connection_failed(error: int) -> void:
	is_connecting = false
	is_connected_to_gdsync = false
	connection_failed.emit(error)


func _build_unique_username() -> String:
	var client_id := str(GDSync.get_client_id())
	var random_id := str(randi_range(1000, 9999))

	return "Player" + client_id + random_id
