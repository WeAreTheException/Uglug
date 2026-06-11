extends Control
class_name MainMenuRoot

@export var map_visual: TextureRect
@export var lobby_icon_layer: Node2D
@export var host_button: Button
@export var join_random_button: Button
@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: Control
@export var connection_handler: MultiplayerConnectionHandler
@export var lobby_host_handler: LobbyHostHandler
@export var lobby_browser: LobbyBrowser
@export var lobby_join_handler: LobbyJoinHandler
@export var lobby_leave_handler: LobbyLeaveHandler
@export var map_spawn_locations: MapSpawnLocations
@export var lobby_icon_spawner: LobbyIconSpawner
@export var status_label: Label

var current_lobbies: Array = []
var is_hosting_lobby := false
var hosted_lobby_name := ""


func _ready() -> void:
	create_lobby_popup.visible = false
	join_private_popup.visible = false

	if map_visual != null:
		map_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

	host_button.disabled = true
	join_random_button.disabled = true

	_set_status("Connecting to GD-Sync...")

	host_button.pressed.connect(_on_host_pressed)
	join_random_button.pressed.connect(_on_join_random_pressed)

	connection_handler.connection_started.connect(_on_connection_started)
	connection_handler.connection_succeeded.connect(_on_connection_succeeded)
	connection_handler.connection_failed.connect(_on_connection_failed)
	connection_handler.start_connection()

	create_lobby_popup.create_requested.connect(_on_create_lobby_requested)

	lobby_host_handler.lobby_create_started.connect(_on_lobby_create_started)
	lobby_host_handler.lobby_create_succeeded.connect(_on_lobby_create_succeeded)
	lobby_host_handler.lobby_create_failed.connect(_on_lobby_create_failed)
	lobby_host_handler.lobby_join_succeeded.connect(_on_host_lobby_join_succeeded)
	lobby_host_handler.lobby_join_failed.connect(_on_host_lobby_join_failed)

	lobby_browser.browse_started.connect(_on_lobby_browse_started)
	lobby_browser.lobbies_updated.connect(_on_lobbies_updated)

	lobby_icon_spawner.lobby_icon_clicked.connect(_on_lobby_icon_clicked)

	lobby_join_handler.join_started.connect(_on_lobby_join_started)
	lobby_join_handler.join_succeeded.connect(_on_public_lobby_join_succeeded)
	lobby_join_handler.join_failed.connect(_on_public_lobby_join_failed)

	lobby_leave_handler.leave_requested.connect(_on_lobby_leave_requested)
	lobby_leave_handler.leave_completed.connect(_on_lobby_leave_completed)

	_test_spawn_locations()


func _on_host_pressed() -> void:
	if is_hosting_lobby:
		lobby_leave_handler.leave_lobby()
		return

	create_lobby_popup.visible = true


func _on_join_random_pressed() -> void:
	lobby_join_handler.join_random_lobby(current_lobbies)


func _on_connection_started() -> void:
	_set_status("Connecting to GD-Sync...")


func _on_connection_succeeded() -> void:
	host_button.text = "Host"
	host_button.disabled = false
	join_random_button.visible = true
	join_random_button.disabled = false
	lobby_browser.start_browsing()
	_set_status("Connected to GD-Sync.")


func _on_connection_failed(error: int) -> void:
	host_button.disabled = true
	join_random_button.disabled = true
	_set_status("GD-Sync connection failed: " + str(error))


func _on_create_lobby_requested(is_private: bool, passcode: String) -> void:
	var spawn_id := map_spawn_locations.get_random_spawn_id()

	_set_status("Creating lobby at spawn " + str(spawn_id) + "...")
	lobby_host_handler.create_lobby(is_private, passcode, spawn_id)


func _on_lobby_create_started() -> void:
	host_button.disabled = true
	join_random_button.disabled = true
	_set_status("Creating lobby...")


func _on_lobby_create_succeeded(lobby_name: String) -> void:
	create_lobby_popup.visible = false
	_set_status("Lobby created. Joining: " + lobby_name)


func _on_lobby_create_failed(lobby_name: String, error: int) -> void:
	host_button.disabled = false
	join_random_button.disabled = false
	_set_status("Lobby creation failed: " + lobby_name + " Error: " + str(error))


func _on_host_lobby_join_succeeded(lobby_name: String, lobby_info: Dictionary) -> void:
	is_hosting_lobby = true
	hosted_lobby_name = lobby_name

	host_button.text = "Leave Lobby"
	host_button.disabled = false
	join_random_button.visible = false

	lobby_icon_spawner.update_lobbies(_get_lobbies_for_map(lobby_info))

	_set_status("Hosting lobby.")


func _on_host_lobby_join_failed(lobby_name: String, error: int) -> void:
	host_button.disabled = false
	join_random_button.disabled = false
	_set_status("Created lobby but failed to join: " + lobby_name + " Error: " + str(error))


func _on_lobby_browse_started() -> void:
	print("Browsing lobbies...")


func _on_lobbies_updated(lobbies: Array) -> void:
	current_lobbies = lobbies
	print("Joinable lobbies found: ", lobbies.size())

	if is_hosting_lobby:
		lobby_icon_spawner.update_lobbies(_get_lobbies_for_map(lobby_host_handler.pending_lobby_info))
	else:
		lobby_icon_spawner.update_lobbies(current_lobbies)


func _on_lobby_icon_clicked(lobby_info: Dictionary) -> void:
	var lobby_name: String = lobby_info.get("lobby_name", "")

	if is_hosting_lobby and lobby_name == hosted_lobby_name:
		print("Clicked own lobby. Ignoring join request.")
		return

	var is_private: bool = lobby_info.get("is_private", false)

	if is_private:
		_set_status("Private lobby join not implemented yet.")
		return

	lobby_join_handler.join_public_lobby(lobby_info)


func _on_lobby_join_started(lobby_name: String) -> void:
	host_button.disabled = true
	join_random_button.disabled = true
	_set_status("Joining lobby: " + lobby_name)


func _on_public_lobby_join_succeeded(lobby_name: String) -> void:
	lobby_browser.stop_browsing()
	_set_status("Joined lobby: " + lobby_name)


func _on_public_lobby_join_failed(lobby_name: String, error: int) -> void:
	host_button.disabled = false
	join_random_button.disabled = false
	_set_status("Failed to join lobby: " + lobby_name + " Error: " + str(error))


func _on_lobby_leave_requested() -> void:
	host_button.disabled = true
	_set_status("Leaving lobby...")


func _on_lobby_leave_completed() -> void:
	is_hosting_lobby = false
	hosted_lobby_name = ""

	host_button.text = "Host"
	host_button.disabled = false
	join_random_button.visible = true
	join_random_button.disabled = false

	lobby_icon_spawner.update_lobbies(current_lobbies)
	lobby_browser.start_browsing()
	_set_status("Connected to GD-Sync.")


func _get_lobbies_for_map(own_lobby_info: Dictionary) -> Array:
	var lobbies := current_lobbies.duplicate()

	if own_lobby_info.is_empty():
		return lobbies

	var own_lobby := own_lobby_info.duplicate()
	own_lobby["is_own_lobby"] = true

	var own_lobby_name: String = own_lobby.get("lobby_name", "")

	for i in range(lobbies.size()):
		if lobbies[i].get("lobby_name", "") == own_lobby_name:
			lobbies[i] = own_lobby
			return lobbies

	lobbies.append(own_lobby)
	return lobbies


func _test_spawn_locations() -> void:
	if map_spawn_locations == null:
		print("Spawn test failed: MapSpawnLocations not assigned.")
		return

	map_spawn_locations.print_spawn_debug()


func _set_status(text: String) -> void:
	if status_label == null:
		return

	status_label.text = text
