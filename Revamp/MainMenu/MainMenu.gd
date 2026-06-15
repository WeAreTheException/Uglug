extends Control
class_name MainMenuRoot

@export var map_visual: TextureRect
@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: JoinPrivatePopup
@export var connection_handler: MultiplayerConnectionHandler
@export var lobby_browser: LobbyBrowser
@export var state_manager: MainMenuStateManager
@export var button_state: MainMenuButtonState
@export var host_flow: MainMenuHostFlow
@export var join_flow: MainMenuJoinFlow
@export var match_flow: MainMenuMatchFlow
@export var map_flow: MainMenuMapFlow
@export var map_spawn_locations: MapSpawnLocations
@export var status_label: Label

@export var print_map_spawn_debug := false
@export var print_lobby_browse_debug := false
@export var print_own_lobby_click_debug := false


func _ready() -> void:
	create_lobby_popup.visible = false
	join_private_popup.visible = false

	if map_visual != null:
		map_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

	state_manager.set_state(MainMenuStateManager.MenuState.CONNECTING)
	_set_status("Connecting to GD-Sync...")

	button_state.host_pressed.connect(host_flow.handle_host_pressed)
	button_state.join_random_pressed.connect(join_flow.handle_join_random_pressed)

	connection_handler.connection_started.connect(_on_connection_started)
	connection_handler.connection_succeeded.connect(_on_connection_succeeded)
	connection_handler.connection_failed.connect(_on_connection_failed)
	connection_handler.start_connection()

	lobby_browser.browse_started.connect(_on_lobby_browse_started)
	lobby_browser.lobbies_updated.connect(map_flow.handle_lobbies_updated)

	map_flow.public_lobby_clicked.connect(join_flow.handle_public_lobby_clicked)
	map_flow.private_lobby_clicked.connect(join_flow.handle_private_lobby_clicked)
	map_flow.own_lobby_clicked.connect(_on_own_lobby_clicked)

	host_flow.status_requested.connect(_set_status)
	join_flow.status_requested.connect(_set_status)
	match_flow.status_requested.connect(_set_status)

	_test_spawn_locations()


func _on_connection_started() -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.CONNECTING)
	_set_status("Connecting to GD-Sync...")


func _on_connection_succeeded() -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.BROWSING)
	lobby_browser.start_browsing()
	_set_status("Connected to GD-Sync.")


func _on_connection_failed(error: int) -> void:
	state_manager.set_state(MainMenuStateManager.MenuState.CONNECTING)
	_set_status("GD-Sync connection failed: " + str(error))


func _on_lobby_browse_started() -> void:
	if print_lobby_browse_debug:
		print("Browsing lobbies...")


func _on_own_lobby_clicked(_lobby_info: Dictionary) -> void:
	if print_own_lobby_click_debug:
		print("Clicked own lobby. Ignoring join request.")


func _test_spawn_locations() -> void:
	if map_spawn_locations == null:
		if print_map_spawn_debug:
			print("Spawn test failed: MapSpawnLocations not assigned.")
		return

	if print_map_spawn_debug:
		map_spawn_locations.print_spawn_debug()


func _set_status(text: String) -> void:
	if status_label == null:
		return

	status_label.text = text
