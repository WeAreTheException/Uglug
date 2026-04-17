extends Node
class_name MainMenu

@export var host_button: Button
@export var join_button: Button
@export var multiplayer_scene: PackedScene

var gdsync_ready: bool = false
var started: bool = false

func _ready() -> void:
	if started:
		return
	started = true

	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)

	GDSync.connected.connect(_on_gdsync_connected)
	GDSync.connection_failed.connect(_on_gdsync_connection_failed)
	GDSync.disconnected.connect(_on_gdsync_disconnected)

	host_button.disabled = true
	join_button.disabled = true

	print("starting GD-Sync...")
	GDSync.start_multiplayer()

func _on_host_button_pressed() -> void:
	if not gdsync_ready:
		print("GD-Sync not connected yet")
		return

	print("host pressed")

func _on_join_button_pressed() -> void:
	if not gdsync_ready:
		print("GD-Sync not connected yet")
		return

	print("join pressed")

func _on_gdsync_connected() -> void:
	gdsync_ready = true
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync connected")

func _on_gdsync_connection_failed(error: int) -> void:
	gdsync_ready = false
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync connection failed: ", error)

func _on_gdsync_disconnected() -> void:
	gdsync_ready = false
	host_button.disabled = false
	join_button.disabled = false
	print("GD-Sync disconnected")
