extends Node
class_name MainMenuMatchFlow

signal status_requested(text: String)

@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: JoinPrivatePopup
@export var state_manager: MainMenuStateManager
@export var lobby_browser: LobbyBrowser
@export var match_start_handler: MatchStartHandler


func _ready() -> void:
	match_start_handler.match_start_requested.connect(_on_match_start_requested)
	match_start_handler.match_start_failed.connect(_on_match_start_failed)


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
