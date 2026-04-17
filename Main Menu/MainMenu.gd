extends Node
class_name MainMenu

@export var host_button: Button
@export var join_button: Button
@export var multiplayer_scene: PackedScene

var gdsync_ready: bool = false
var started: bool = false
var is_creating_lobby: bool = false
var is_joining_lobby: bool = false

func _ready() -> void:
	if started:
		return
	started = true

	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)

	if not GDSync.connected.is_connected(_on_gdsync_connected):
		GDSync.connected.connect(_on_gdsync_connected)

	if not GDSync.connection_failed.is_connected(_on_gdsync_connection_failed):
		GDSync.connection_failed.connect(_on_gdsync_connection_failed)

	if not GDSync.disconnected.is_connected(_on_gdsync_disconnected):
		GDSync.disconnected.connect(_on_gdsync_disconnected)

	if not GDSync.lobby_created.is_connected(_on_lobby_created):
		GDSync.lobby_created.connect(_on_lobby_created)

	if not GDSync.lobby_creation_failed.is_connected(_on_lobby_creation_failed):
		GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)

	if not GDSync.lobbies_received.is_connected(_on_lobbies_received):
		GDSync.lobbies_received.connect(_on_lobbies_received)

	if not GDSync.lobby_joined.is_connected(_on_lobby_joined):
		GDSync.lobby_joined.connect(_on_lobby_joined)

	if not GDSync.lobby_join_failed.is_connected(_on_lobby_join_failed):
		GDSync.lobby_join_failed.connect(_on_lobby_join_failed)

	host_button.disabled = true
	join_button.disabled = true

	if GDSync.is_active():
		gdsync_ready = true
		host_button.disabled = false
		join_button.disabled = false
		print("GD-Sync already active")
	else:
		print("starting GD-Sync...")
		GDSync.start_multiplayer()

func _on_host_button_pressed() -> void:
	if not gdsync_ready:
		print("GD-Sync not connected yet")
		return

	if is_creating_lobby or is_joining_lobby:
		print("busy")
		return

	is_creating_lobby = true
	host_button.disabled = true
	join_button.disabled = true

	var lobby_name := "Lobby_%s" % str(Time.get_unix_time_from_system())
	print("creating lobby: ", lobby_name)

	GDSync.lobby_create(lobby_name, "", true, 2)

func _on_join_button_pressed() -> void:
	if not gdsync_ready:
		print("GD-Sync not connected yet")
		return

	if is_creating_lobby or is_joining_lobby:
		print("busy")
		return

	is_joining_lobby = true
	host_button.disabled = true
	join_button.disabled = true

	print("requesting public lobbies")
	GDSync.get_public_lobbies()

func _on_gdsync_connected() -> void:
	gdsync_ready = true
	if not is_creating_lobby and not is_joining_lobby:
		host_button.disabled = false
		join_button.disabled = false
	print("GD-Sync connected")

func _on_gdsync_connection_failed(error: int) -> void:
	gdsync_ready = false
	is_creating_lobby = false
	is_joining_lobby = false
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync connection failed: ", error)

func _on_gdsync_disconnected() -> void:
	gdsync_ready = false
	is_creating_lobby = false
	is_joining_lobby = false
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync disconnected")

func _on_lobby_created(lobby_name: String) -> void:
	is_creating_lobby = false
	print("lobby created: ", lobby_name)
	get_tree().change_scene_to_packed(multiplayer_scene)

func _on_lobby_creation_failed(lobby_name: String, error: int) -> void:
	is_creating_lobby = false
	host_button.disabled = false
	join_button.disabled = false
	print("lobby creation failed: ", lobby_name, " error: ", error)

func _on_lobbies_received(lobbies: Array) -> void:
	print("public lobbies received: ", lobbies.size())

	if not is_joining_lobby:
		return

	if lobbies.is_empty():
		is_joining_lobby = false
		host_button.disabled = false
		join_button.disabled = false
		print("no public lobbies found")
		return

	var lobby: Dictionary = lobbies[0]
	var lobby_name: String = str(lobby.get("Name", ""))

	if lobby_name == "":
		is_joining_lobby = false
		host_button.disabled = false
		join_button.disabled = false
		print("first lobby had no valid name")
		return

	print("joining lobby: ", lobby_name)
	GDSync.lobby_join(lobby_name)

func _on_lobby_joined(lobby_name: String) -> void:
	is_joining_lobby = false
	print("lobby joined: ", lobby_name)
	get_tree().change_scene_to_packed(multiplayer_scene)

func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	is_joining_lobby = false
	host_button.disabled = false
	join_button.disabled = false
	print("lobby join failed: ", lobby_name, " error: ", error)
