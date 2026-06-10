extends Control
class_name MainMenuRoot

@export var map_visual: TextureRect
@export var lobby_icon_layer: Control
@export var host_button: Button
@export var join_random_button: Button
@export var create_lobby_popup: CreateLobbyPopup
@export var join_private_popup: Control
@export var connection_handler: MultiplayerConnectionHandler
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


func _on_host_pressed() -> void:
	create_lobby_popup.visible = true


func _on_join_random_pressed() -> void:
	_set_status("Join Random not implemented yet.")


func _on_connection_started() -> void:
	_set_status("Connecting to GD-Sync...")


func _on_connection_succeeded() -> void:
	_set_status("Connected to GD-Sync.")
	host_button.disabled = false
	join_random_button.disabled = false


func _on_connection_failed(error: int) -> void:
	_set_status("GD-Sync connection failed: " + str(error))
	host_button.disabled = true
	join_random_button.disabled = true


func _set_status(text: String) -> void:
	if status_label == null:
		return

	status_label.text = text

func _on_create_lobby_requested(is_private: bool, passcode: String) -> void:
	print("Create lobby requested. Private: ", is_private, " Passcode: ", passcode)
	_set_status("Create lobby requested. Multiplayer creation not implemented yet.")
