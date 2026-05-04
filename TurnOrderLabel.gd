extends Node
class_name MatchStartBanner

@export var first_player_label: Label
@export var visible_seconds: float = 2.5

func _ready() -> void:
	if first_player_label != null:
		first_player_label.visible = false

	GDSync.expose_node(self)
	GDSync.expose_func(show_first_player_banner)

	await get_tree().create_timer(1.0).timeout

	if GDSync.is_host():
		choose_and_show_first_player()


func choose_and_show_first_player() -> void:
	var clients := GDSync.lobby_get_all_clients()

	if clients.size() < 2:
		print("MatchStartBanner: not enough clients")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var first_index := rng.randi_range(0, clients.size() - 1)
	var first_player_id := int(clients[first_index])
	var first_player_name := GDSync.player_get_username(first_player_id, "Unknown Player")

	print("MatchStartBanner: first player is ", first_player_name)

	GDSync.call_func_all(show_first_player_banner, first_player_name)


func show_first_player_banner(first_player_name: String) -> void:
	if first_player_label == null:
		return

	first_player_label.text = first_player_name + " is placing first"
	first_player_label.visible = true

	await get_tree().create_timer(visible_seconds).timeout

	if first_player_label != null:
		first_player_label.visible = false
