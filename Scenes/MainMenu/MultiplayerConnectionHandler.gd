extends Node
class_name MultiplayerConnectionHandler

signal connection_started
signal connection_succeeded
signal connection_failed(error: int)

var is_connected_to_gdsync := false
var is_connecting := false

@export var force_connection_failure := false


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
	connection_succeeded.emit()


func _on_connection_failed(error: int) -> void:
	is_connecting = false
	is_connected_to_gdsync = false
	connection_failed.emit(error)
