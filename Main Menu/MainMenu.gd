extends Node
class_name MainMenu

const PORT := 9999

@export var host_button: Button
@export var join_button: Button
@export var multiplayer_scene: PackedScene

var peer := ENetMultiplayerPeer.new()

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)

func _on_host_button_pressed() -> void:
	var error := peer.create_server(PORT)
	if error != OK:
		print("failed to host server: ", error)
		return

	multiplayer.multiplayer_peer = peer
	print("server hosted on port: ", PORT)

	get_tree().change_scene_to_packed(multiplayer_scene)
