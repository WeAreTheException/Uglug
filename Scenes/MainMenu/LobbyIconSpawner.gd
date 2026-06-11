extends Node
class_name LobbyIconSpawner

signal lobby_icon_clicked(lobby_info: Dictionary)

@export var lobby_icon_scene: PackedScene
@export var lobby_icon_layer: Node2D
@export var map_spawn_locations: MapSpawnLocations

var spawned_icons := {}


func update_lobbies(lobbies: Array) -> void:
	var active_lobby_names := []

	for lobby_info in lobbies:
		var lobby_name: String = lobby_info.get("lobby_name", "")
		if lobby_name == "":
			continue

		active_lobby_names.append(lobby_name)

		if spawned_icons.has(lobby_name):
			continue

		_spawn_lobby_icon(lobby_info)

	_remove_closed_lobbies(active_lobby_names)


func _spawn_lobby_icon(lobby_info: Dictionary) -> void:
	if lobby_icon_scene == null:
		return

	var icon := lobby_icon_scene.instantiate() as LobbyColonyIcon
	if icon == null:
		return

	var spawn_id: int = lobby_info.get("spawn_id", 0)
	icon.global_position = map_spawn_locations.get_spawn_position(spawn_id)

	lobby_icon_layer.add_child(icon)
	icon.setup(lobby_info)
	icon.lobby_clicked.connect(_on_lobby_icon_clicked)

	spawned_icons[lobby_info.get("lobby_name", "")] = icon


func _remove_closed_lobbies(active_lobby_names: Array) -> void:
	for lobby_name in spawned_icons.keys():
		if active_lobby_names.has(lobby_name):
			continue

		var icon: Node = spawned_icons[lobby_name]
		spawned_icons.erase(lobby_name)
		icon.queue_free()


func _on_lobby_icon_clicked(lobby_info: Dictionary) -> void:
	lobby_icon_clicked.emit(lobby_info)
