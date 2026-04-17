extends Node
class_name MainMenu

const PORT := 9999

@export var host_button: Button
@export var join_button: Button
@export var address_input: LineEdit
@export var multiplayer_scene: PackedScene

var peer := ENetMultiplayerPeer.new()

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_host_button_pressed() -> void:
	host_button.disabled = true
	join_button.disabled = true

	var error := peer.create_server(PORT)
	if error != OK:
		print("failed to host server: ", error)
		host_button.disabled = false
		join_button.disabled = false
		return

	multiplayer.multiplayer_peer = peer
	print("server hosted on port: ", PORT)

	get_tree().change_scene_to_packed(multiplayer_scene)

func _on_join_button_pressed() -> void:
	host_button.disabled = true
	join_button.disabled = true

	var address := address_input.text.strip_edges()

	if address == "":
		print("no address entered")
		host_button.disabled = false
		join_button.disabled = false
		return

	var error := peer.create_client(address, PORT)
	if error != OK:
		print("failed to start join attempt: ", error)
		host_button.disabled = false
		join_button.disabled = false
		return

	multiplayer.multiplayer_peer = peer
	print("attempting to join server at: ", address, ":", PORT)

func _on_connected_to_server() -> void:
	print("successfully connected to server")
	get_tree().change_scene_to_packed(multiplayer_scene)

func _on_connection_failed() -> void:
	print("connection failed")
	host_button.disabled = false
	join_button.disabled = false
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	print("server disconnected")
	host_button.disabled = false
	join_button.disabled = false
	multiplayer.multiplayer_peer = null
