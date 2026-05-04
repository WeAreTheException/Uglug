extends Node2D

@export var code_label: Label
@export var status_label: Label
@export var multiplayer_scene: PackedScene
@export var start_timer: Timer

var has_started := false

func _ready() -> void:
	print("entered waiting room")

	var lobby_name := GDSync.lobby_get_name()
	code_label.text = "Code: " + lobby_name

	if not GDSync.client_joined.is_connected(_on_client_joined):
		GDSync.client_joined.connect(_on_client_joined)

	if not GDSync.client_left.is_connected(_on_client_left):
		GDSync.client_left.connect(_on_client_left)

	if start_timer != null:
		start_timer.timeout.connect(_on_start_timer_timeout)

	update_status()
	check_start()


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
	print("lobby count = ", count)


func check_start() -> void:
	if has_started:
		return

	var count := GDSync.lobby_get_player_count()

	if count < 2:
		return

	has_started = true

	print("2 players ready → preparing start")

	# UI update
	status_label.text = "Players: 2 / 2"
	code_label.text = "Starting match..."

	# delay before scene change
	if start_timer != null:
		start_timer.start()
	else:
		await get_tree().create_timer(2.0).timeout
		start_match()


func _on_start_timer_timeout() -> void:
	start_match()


func start_match() -> void:
	# 🔥 PREVENT DOUBLE SCENE CHANGE
	if get_tree().current_scene.scene_file_path == multiplayer_scene.resource_path:
		return

	print("starting match now")

	GDSync.change_scene(multiplayer_scene.resource_path)
