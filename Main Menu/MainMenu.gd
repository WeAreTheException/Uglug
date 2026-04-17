extends Node
class_name MainMenu

@export var host_button: Button
@export var join_button: Button
@export var multiplayer_scene: PackedScene

var gdsync_ready: bool = false
var started: bool = false
var pending_lobby_name: String = ""
var is_searching_lobbies: bool = false

func _ready() -> void:
	if started:
		return
	started = true

	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)

	GDSync.connected.connect(_on_gdsync_connected)
	GDSync.connection_failed.connect(_on_gdsync_connection_failed)
	GDSync.disconnected.connect(_on_gdsync_disconnected)

	GDSync.lobby_created.connect(_on_lobby_created)
	GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)
	GDSync.lobby_joined.connect(_on_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_lobby_join_failed)
	GDSync.lobbies_received.connect(_on_lobbies_received)

	host_button.disabled = true
	join_button.disabled = true

	print("starting GD-Sync...")
	GDSync.start_multiplayer()

func _on_host_button_pressed() -> void:
	if not gdsync_ready:
		print("GD-Sync not connected yet")
		return

	host_button.disabled = true
	join_button.disabled = true

	var steam_name := "Player"
	if Engine.has_singleton("Steam") and Steam.isSteamRunning():
		steam_name = Steam.getPersonaName()

	var safe_name := steam_name.strip_edges()
	if safe_name.length() < 3:
		safe_name = "PlayerHost"

	pending_lobby_name = "%s_%s" % [safe_name, str(Time.get_unix_time_from_system())]

	print("creating lobby: ", pending_lobby_name)

	GDSync.lobby_create(
		pending_lobby_name,
		"",
		true,
		2,
		{
			"host_name": steam_name
		}
	)

func _on_join_button_pressed() -> void:
	if not gdsync_ready:
		print("GD-Sync not connected yet")
		return

	host_button.disabled = true
	join_button.disabled = true
	is_searching_lobbies = true

	print("searching public lobbies...")
	GDSync.get_public_lobbies()

func _on_gdsync_connected() -> void:
	gdsync_ready = true
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync connected")

func _on_gdsync_connection_failed(error: int) -> void:
	gdsync_ready = false
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync connection failed: ", error)

func _on_gdsync_disconnected() -> void:
	gdsync_ready = false
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync disconnected")

func _on_lobby_created(lobby_name: String) -> void:
	print("lobby created: ", lobby_name)
	GDSync.lobby_join(lobby_name, "")

func _on_lobby_creation_failed(lobby_name: String, error: int) -> void:
	print("lobby creation failed: ", lobby_name, " error=", error)
	host_button.disabled = false
	join_button.disabled = false

func _on_lobby_joined(lobby_name: String) -> void:
	print("lobby joined: ", lobby_name)
	get_tree().change_scene_to_packed(multiplayer_scene)

func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	print("lobby join failed: ", lobby_name, " error=", error)
	host_button.disabled = false
	join_button.disabled = false
	is_searching_lobbies = false

func _on_lobbies_received(lobbies: Array) -> void:
	if not is_searching_lobbies:
		return

	is_searching_lobbies = false

	print("public lobbies found: ", lobbies.size())

	if lobbies.is_empty():
		print("no public lobbies found")
		host_button.disabled = false
		join_button.disabled = false
		return

	var lobby = lobbies[0]
	var lobby_name: String = ""

	if typeof(lobby) == TYPE_STRING:
		lobby_name = lobby
	elif typeof(lobby) == TYPE_DICTIONARY:
		if lobby.has("Name"):
			lobby_name = str(lobby["Name"])
		elif lobby.has("name"):
			lobby_name = str(lobby["name"])
		elif lobby.has("lobby_name"):
			lobby_name = str(lobby["lobby_name"])

	if lobby_name == "":
		print("failed to parse public lobby entry: ", lobby)
		host_button.disabled = false
		join_button.disabled = false
		return

	print("joining public lobby: ", lobby_name)
	GDSync.lobby_join(lobby_name, "")
