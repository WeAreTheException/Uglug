extends Node
class_name MainMenuHostFlow

signal status_requested(text: String)

@export var create_lobby_popup: CreateLobbyPopup
@export var state_manager: MainMenuStateManager
@export var lobby_host_handler: LobbyHostHandler
@export var lobby_leave_handler: LobbyLeaveHandler
@export var lobby_browser: LobbyBrowser
@export var map_spawn_locations: MapSpawnLocations
@export var map_flow: MainMenuMapFlow


func _ready() -> void:
	create_lobby_popup.create_requested.connect(_on_create_lobby_requested)

	lobby_host_handler.lobby_create_started.connect(_on_lobby_create_started)
	lobby_host_handler.lobby_create_succeeded.connect(_on_lobby_create_succeeded)
	lobby_host_handler.lobby_create_failed.connect(_on_lobby_create_failed)
	lobby_host_handler.lobby_join_succeeded.connect(_on_host_lobby_join_succeeded)
	lobby_host_handler.lobby_join_failed.connect(_on_host_lobby_join_failed)

	lobby_leave_handler.leave_requested.connect(_on_lobby_leave_requested)
	lobby_leave_handler.leave_completed.connect(_on_lobby_leave_completed)


func handle_host_pressed() -> void:
	if state_manager.is_hosting():
		lobby_leave_handler.leave_lobby()
		return

	create_lobby_popup.visible = true


func _on_create_lobby_requested(is_private: bool, passcode: String) -> void:
	var spawn_id := map_spawn_locations.get_random_spawn_id()
	lobby_host_handler.create_lobby(is_private, passcode, spawn_id)


func _on_lobby_create_started() -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.CREATING_LOBBY)
	status_requested.emit("Creating lobby...")


func _on_lobby_create_succeeded(lobby_name: String) -> void:
	create_lobby_popup.visible = false
	status_requested.emit("Lobby created. Joining: " + lobby_name)


func _on_lobby_create_failed(lobby_name: String, error: int) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)
	status_requested.emit("Lobby creation failed: " + lobby_name + " Error: " + str(error))


func _on_host_lobby_join_succeeded(lobby_name: String, lobby_info: Dictionary) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.HOSTING_LOBBY)
	map_flow.set_hosted_lobby(lobby_name, lobby_info)
	lobby_browser.start_browsing()
	status_requested.emit("Hosting lobby.")


func _on_host_lobby_join_failed(lobby_name: String, error: int) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)
	status_requested.emit("Created lobby but failed to join: " + lobby_name + " Error: " + str(error))


func _on_lobby_leave_requested() -> void:
	status_requested.emit("Leaving lobby...")


func _on_lobby_leave_completed() -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)
	map_flow.clear_hosted_lobby()
	lobby_browser.start_browsing()
	status_requested.emit("Connected to GD-Sync.")
