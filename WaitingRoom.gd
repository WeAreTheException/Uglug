extends Node2D

@export var code_label: Label
@export var status_label: Label
@export var multiplayer_scene: PackedScene

var has_started := false

func _ready() -> void:
	print("entered waiting room")

	var lobby_name := GDSync.lobby_get_name()
	code_label.text = "Code: " + lobby_name

	update_status()

	if not GDSync.client_joined.is_connected(_on_client_joined):
		GDSync.client_joined.connect(_on_client_joined)

	if not GDSync.client_left.is_connected(_on_client_left):
		GDSync.client_left.connect(_on_client_left)


func _on_client_joined(client_id: int) -> void:
	print("client joined: ", client_id)
	update_status()
	check_start()


func _on_client_left(client_id: int) -> void:
	print("client left: ", client_id)
	update_status()


func update_status() -> void:
	var count := GDSync.lobby_get_player_count()
	status_label.text = "Players: %d / 2" % count


func check_start() -> void:
	if has_started:
		return

	var count := GDSync.lobby_get_player_count()

	if count < 2:
		return

	has_started = true

	print("2 players ready → starting match")

	# ✅ THIS IS IMPORTANT — use GD-Sync scene change
	GDSync.change_scene(multiplayer_scene.resource_path)
