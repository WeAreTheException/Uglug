extends Control
class_name MainMenuRoot

@export var map_visual: TextureRect
@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: JoinPrivatePopup
@export var connection_handler: MultiplayerConnectionHandler
@export var lobby_browser: LobbyBrowser
@export var lobby_icon_spawner: LobbyIconSpawner
@export var state_manager: MainMenuStateManager
@export var button_state: MainMenuButtonState
@export var lobby_flow: MainMenuLobbyFlow
@export var map_spawn_locations: MapSpawnLocations
@export var status_label: Label


func _ready() -> void:
	create_lobby_popup.visible = false
	join_private_popup.visible = false

	if map_visual != null:
		map_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

	state_manager.set_state(MainMenuStateManager.MenuState.CONNECTING)
	_set_status("Connecting to GD-Sync...")

	button_state.host_pressed.connect(_on_host_pressed)
	button_state.join_random_pressed.connect(_on_join_random_pressed)

	connection_handler.connection_started.connect(_on_connection_started)
	connection_handler.connection_succeeded.connect(_on_connection_succeeded)
	connection_handler.connection_failed.connect(_on_connection_failed)
	connection_handler.start_connection()

	lobby_browser.browse_started.connect(_on_lobby_browse_started)
	lobby_browser.lobbies_updated.connect(_on_lobbies_updated)

	lobby_icon_spawner.lobby_icon_clicked.connect(_on_lobby_icon_clicked)

	lobby_flow.status_requested.connect(_set_status)

	_test_spawn_locations()


func _on_host_pressed() -> void:
	lobby_flow.handle_host_pressed()


func _on_join_random_pressed() -> void:
	lobby_flow.handle_join_random_pressed()


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
	print("Browsing lobbies...")


func _on_lobbies_updated(lobbies: Array) -> void:
	lobby_flow.handle_lobbies_updated(lobbies)


func _on_lobby_icon_clicked(lobby_info: Dictionary) -> void:
	lobby_flow.handle_lobby_icon_clicked(lobby_info)


func _test_spawn_locations() -> void:
	if map_spawn_locations == null:
		print("Spawn test failed: MapSpawnLocations not assigned.")
		return

	map_spawn_locations.print_spawn_debug()


func _set_status(text: String) -> void:
	if status_label == null:
		return

	status_label.text = text
