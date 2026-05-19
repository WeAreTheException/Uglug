extends Node
class_name TuggaHandler

signal scale_changed(value: int)
signal game_ended(winning_peer_id: int)

@export var max_value: int = 5
@export var win_screen_scene: PackedScene
@export var lose_screen_scene: PackedScene

var current_value: int = 0
var game_is_over: bool = false


func _ready() -> void:
	add_to_group("tugga")

	GDSync.expose_node(self)
	GDSync.expose_func(request_direct_damage)
	GDSync.expose_func(commit_tugga_value)

	scale_changed.emit(current_value)


func request_direct_damage(attacker_peer_id: int, amount: int) -> void:
	if GDSync.is_host():
		take_direct_damage(attacker_peer_id, amount)
	else:
		GDSync.call_func(request_direct_damage, attacker_peer_id, amount)


func take_direct_damage(attacker_peer_id: int, amount: int) -> void:
	if game_is_over:
		return

	if amount <= 0:
		return

	if not GDSync.is_host():
		request_direct_damage(attacker_peer_id, amount)
		return

	var player_one_id := _get_player_one_id()

	if attacker_peer_id == player_one_id:
		current_value -= amount
	else:
		current_value += amount

	current_value = clamp(current_value, -max_value, max_value)

	print("tugga host value: ", current_value)

	GDSync.call_func_all(commit_tugga_value, current_value)


func commit_tugga_value(value: int) -> void:
	if game_is_over:
		return

	current_value = clamp(value, -max_value, max_value)

	print("tugga synced value: ", current_value)

	scale_changed.emit(current_value)
	_check_for_game_end_locally()


func _check_for_game_end_locally() -> void:
	if game_is_over:
		return

	if current_value >= max_value:
		_end_game_locally(_get_player_two_id())
	elif current_value <= -max_value:
		_end_game_locally(_get_player_one_id())


func _end_game_locally(winning_peer_id: int) -> void:
	if game_is_over:
		return

	game_is_over = true

	print("GAME ENDED LOCALLY. WINNER: ", winning_peer_id)

	game_ended.emit(winning_peer_id)

	var my_peer_id := int(GDSync.get_client_id())

	if my_peer_id == winning_peer_id:
		_change_to_screen.call_deferred(win_screen_scene)
	else:
		_change_to_screen.call_deferred(lose_screen_scene)


func _change_to_screen(screen_scene: PackedScene) -> void:
	if screen_scene == null:
		print("end screen blocked: scene is null")
		return

	var tree := get_tree()

	if tree == null:
		return

	tree.change_scene_to_packed(screen_scene)


func _get_player_one_id() -> int:
	var tree := get_tree()

	if tree == null:
		return int(GDSync.get_client_id())

	var turn_manager := tree.get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		print("tugga warning: turn_manager not found, using local client as player one")
		return int(GDSync.get_client_id())

	return turn_manager.player_one_id


func _get_player_two_id() -> int:
	var tree := get_tree()

	if tree == null:
		return int(GDSync.get_client_id())

	var turn_manager := tree.get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		print("tugga warning: turn_manager not found, using local client as player two")
		return int(GDSync.get_client_id())

	return turn_manager.player_two_id
