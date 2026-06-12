extends Node
class_name MainMenuJoinFlow

signal status_requested(text: String)

@export var state_manager: MainMenuStateManager
@export var lobby_join_handler: LobbyJoinHandler
@export var lobby_leave_handler: LobbyLeaveHandler
@export var lobby_browser: LobbyBrowser
@export var private_join_flow: MainMenuPrivateJoinFlow
@export var map_flow: MainMenuMapFlow


func _ready() -> void:
	lobby_join_handler.join_started.connect(_on_lobby_join_started)
	lobby_join_handler.join_succeeded.connect(_on_lobby_join_succeeded)
	lobby_join_handler.join_failed.connect(_on_lobby_join_failed)

	private_join_flow.private_join_requested.connect(_on_private_join_requested)


func handle_join_random_pressed() -> void:
	lobby_join_handler.join_random_lobby(map_flow.get_current_lobbies())


func handle_public_lobby_clicked(lobby_info: Dictionary) -> void:
	if state_manager.is_hosting():
		print("Leaving hosted lobby before joining another lobby.")
		lobby_leave_handler.leave_lobby()

	lobby_join_handler.join_public_lobby(lobby_info)


func handle_private_lobby_clicked(lobby_info: Dictionary) -> void:
	private_join_flow.open_for_lobby(lobby_info)


func _on_private_join_requested(lobby_info: Dictionary, passcode: String) -> void:
	if state_manager.is_hosting():
		print("Leaving hosted lobby before joining private lobby.")
		lobby_leave_handler.leave_lobby()

	lobby_join_handler.join_private_lobby(lobby_info, passcode)


func _on_lobby_join_started(lobby_name: String) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.JOINING_LOBBY)
	status_requested.emit("Joining lobby: " + lobby_name)


func _on_lobby_join_succeeded(lobby_name: String) -> void:
	private_join_flow.clear()
	lobby_browser.stop_browsing()
	status_requested.emit("Joined lobby: " + lobby_name)


func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)

	if error == ENUMS.LOBBY_JOIN_ERROR.INCORRECT_PASSWORD:
		private_join_flow.show_incorrect_password()
		return

	if error == ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
		private_join_flow.show_lobby_missing()
		return

	status_requested.emit("Failed to join lobby: " + lobby_name + " Error: " + str(error))
