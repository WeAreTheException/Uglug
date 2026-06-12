extends Node
class_name MainMenuLobbyFlow

signal status_requested(text: String)

@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: JoinPrivatePopup
@export var state_manager: MainMenuStateManager
@export var lobby_host_handler: LobbyHostHandler
@export var lobby_browser: LobbyBrowser
@export var lobby_join_handler: LobbyJoinHandler
@export var lobby_leave_handler: LobbyLeaveHandler
@export var private_join_flow: MainMenuPrivateJoinFlow
@export var match_start_handler: MatchStartHandler
@export var map_spawn_locations: MapSpawnLocations
@export var lobby_icon_spawner: LobbyIconSpawner

var current_lobbies: Array = []
var hosted_lobby_name := ""
var lobby_map_presenter := MainMenuLobbyMapPresenter.new()


func _ready() -> void:
	create_lobby_popup.create_requested.connect(_on_create_lobby_requested)

	lobby_host_handler.lobby_create_started.connect(_on_lobby_create_started)
	lobby_host_handler.lobby_create_succeeded.connect(_on_lobby_create_succeeded)
	lobby_host_handler.lobby_create_failed.connect(_on_lobby_create_failed)
	lobby_host_handler.lobby_join_succeeded.connect(_on_host_lobby_join_succeeded)
	lobby_host_handler.lobby_join_failed.connect(_on_host_lobby_join_failed)

	lobby_join_handler.join_started.connect(_on_lobby_join_started)
	lobby_join_handler.join_succeeded.connect(_on_public_lobby_join_succeeded)
	lobby_join_handler.join_failed.connect(_on_public_lobby_join_failed)

	lobby_leave_handler.leave_requested.connect(_on_lobby_leave_requested)
	lobby_leave_handler.leave_completed.connect(_on_lobby_leave_completed)

	private_join_flow.private_join_requested.connect(_on_private_join_requested)

	match_start_handler.match_start_requested.connect(_on_match_start_requested)
	match_start_handler.match_start_failed.connect(_on_match_start_failed)


func handle_host_pressed() -> void:
	if state_manager.is_hosting():
		lobby_leave_handler.leave_lobby()
		return

	create_lobby_popup.visible = true


func handle_join_random_pressed() -> void:
	lobby_join_handler.join_random_lobby(current_lobbies)


func handle_lobbies_updated(lobbies: Array) -> void:
	current_lobbies = lobbies
	print("Joinable lobbies found: ", lobbies.size())
	_update_lobby_map(lobby_host_handler.pending_lobby_info)


func handle_lobby_icon_clicked(lobby_info: Dictionary) -> void:
	var lobby_name: String = lobby_info.get("lobby_name", "")

	if state_manager.is_hosting() and lobby_name == hosted_lobby_name:
		print("Clicked own lobby. Ignoring join request.")
		return

	if lobby_info.get("is_private", false):
		private_join_flow.open_for_lobby(lobby_info)
		return

	if state_manager.is_hosting():
		print("Leaving hosted lobby before joining another lobby.")
		lobby_leave_handler.leave_lobby()

	lobby_join_handler.join_public_lobby(lobby_info)


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
	hosted_lobby_name = lobby_name
	state_manager.set_state(MainMenuStateManager.MenuState.HOSTING_LOBBY)

	_update_lobby_map(lobby_info)
	lobby_browser.start_browsing()

	status_requested.emit("Hosting lobby.")


func _on_host_lobby_join_failed(lobby_name: String, error: int) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)
	status_requested.emit("Created lobby but failed to join: " + lobby_name + " Error: " + str(error))


func _on_private_join_requested(lobby_info: Dictionary, passcode: String) -> void:
	if state_manager.is_hosting():
		print("Leaving hosted lobby before joining private lobby.")
		lobby_leave_handler.leave_lobby()

	lobby_join_handler.join_private_lobby(lobby_info, passcode)


func _on_lobby_join_started(lobby_name: String) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.JOINING_LOBBY)
	status_requested.emit("Joining lobby: " + lobby_name)


func _on_public_lobby_join_succeeded(lobby_name: String) -> void:
	private_join_flow.clear()
	lobby_browser.stop_browsing()
	status_requested.emit("Joined lobby: " + lobby_name)


func _on_public_lobby_join_failed(lobby_name: String, error: int) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)

	if error == ENUMS.LOBBY_JOIN_ERROR.INCORRECT_PASSWORD:
		private_join_flow.show_incorrect_password()
		return

	if error == ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
		private_join_flow.show_lobby_missing()
		return

	status_requested.emit("Failed to join lobby: " + lobby_name + " Error: " + str(error))


func _on_lobby_leave_requested() -> void:
	status_requested.emit("Leaving lobby...")


func _on_lobby_leave_completed() -> void:
	hosted_lobby_name = ""
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)

	_update_lobby_map({})
	lobby_browser.start_browsing()

	status_requested.emit("Connected to GD-Sync.")


func _on_match_start_requested() -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.TRANSITIONING_TO_GAME)

	create_lobby_popup.visible = false
	join_private_popup.visible = false
	lobby_browser.stop_browsing()

	status_requested.emit("Starting match...")


func _on_match_start_failed(reason: String) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)
	lobby_browser.start_browsing()
	status_requested.emit(reason)


func _update_lobby_map(own_lobby_info: Dictionary) -> void:
	var map_lobbies := lobby_map_presenter.build_lobbies_for_map(
		current_lobbies,
		own_lobby_info,
		state_manager.is_hosting()
	)

	lobby_icon_spawner.update_lobbies(map_lobbies)
