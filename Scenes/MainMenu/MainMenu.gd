extends Control
class_name MainMenuRoot

@export var map_visual: TextureRect
@export var lobby_icon_layer: Control
@export var host_button: Button
@export var join_random_button: Button
@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: Control
@export var connection_handler: MultiplayerConnectionHandler
@export var lobby_host_handler: LobbyHostHandler
@export var lobby_browser: LobbyBrowser
@export var status_label: Label


func _ready() -> void:
	create_lobby_popup.visible = false
	join_private_popup.visible = false

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
	lobby_host_handler.lobby_join_succeeded.connect(_on_lobby_join_succeeded)
	lobby_host_handler.lobby_join_failed.connect(_on_lobby_join_failed)

	lobby_browser.browse_started.connect(_on_lobby_browse_started)
	lobby_browser.lobbies_updated.connect(_on_lobbies_updated)


func _on_host_pressed() -> void:
	create_lobby_popup.visible = true


func _on_join_random_pressed() -> void:
	_set_status("Join Random not implemented yet.")


func _on_connection_started() -> void:
	_set_status("Connecting to GD-Sync...")


func _on_connection_succeeded() -> void:
	host_button.disabled = false
	join_random_button.disabled = false
	lobby_browser.start_browsing()
	_set_status("Connected. Browsing lobbies...")


func _on_connection_failed(error: int) -> void:
	host_button.disabled = true
	join_random_button.disabled = true
	_set_status("GD-Sync connection failed: " + str(error))


func _on_create_lobby_requested(is_private: bool, passcode: String) -> void:
	_set_status("Creating lobby...")
	lobby_host_handler.create_lobby(is_private, passcode)


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


func _on_lobby_join_succeeded(lobby_name: String) -> void:
	_set_status("Joined own lobby: " + lobby_name)


func _on_lobby_join_failed(lobby_name: String, error: int) -> void:
	host_button.disabled = false
	join_random_button.disabled = false
	_set_status("Created lobby but failed to join: " + lobby_name + " Error: " + str(error))


func _on_lobby_browse_started() -> void:
	print("Browsing lobbies...")


func _on_lobbies_updated(lobbies: Array) -> void:
	print("Lobbies found: ", lobbies.size())
	_set_status("Connected. Lobbies found: " + str(lobbies.size()))


func _set_status(text: String) -> void:
	if status_label == null:
		return

	status_label.text = text
