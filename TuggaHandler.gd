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
	scale_changed.emit(current_value)


func take_direct_damage(attacker_peer_id: int, amount: int) -> void:
	if game_is_over:
		return

	if amount <= 0:
		return

	var player_one_id := _get_player_one_id()

	if attacker_peer_id == player_one_id:
		add_to_player_one(amount)
	else:
		add_to_player_two(amount)


func add_to_player_one(amount: int) -> void:
	if game_is_over:
		return

	current_value += amount
	current_value = clamp(current_value, -max_value, max_value)

	print("tugga: ", current_value)

	scale_changed.emit(current_value)
	_check_for_game_end()


func add_to_player_two(amount: int) -> void:
	if game_is_over:
		return

	current_value -= amount
	current_value = clamp(current_value, -max_value, max_value)

	print("tugga: ", current_value)

	scale_changed.emit(current_value)
	_check_for_game_end()


func _check_for_game_end() -> void:
	if game_is_over:
		return

	if current_value >= max_value:
		_end_game(_get_player_one_id())

	elif current_value <= -max_value:
		_end_game(_get_player_two_id())


func _end_game(winning_peer_id: int) -> void:
	game_is_over = true

	print("GAME ENDED. WINNER: ", winning_peer_id)

	game_ended.emit(winning_peer_id)

	var my_peer_id := int(GDSync.get_client_id())

	if my_peer_id == winning_peer_id:
		_show_screen(win_screen_scene)
	else:
		_show_screen(lose_screen_scene)


func _show_screen(screen_scene: PackedScene) -> void:
	if screen_scene == null:
		print("end screen blocked: scene is null")
		return

	get_tree().change_scene_to_packed(screen_scene)


func _get_player_one_id() -> int:
	var turn_manager := get_tree().get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		print("tugga warning: turn_manager not found, using local client as player one")
		return int(GDSync.get_client_id())

	return turn_manager.player_one_id


func _get_player_two_id() -> int:
	var turn_manager := get_tree().get_first_node_in_group("turn_manager") as TurnManager

	if turn_manager == null:
		print("tugga warning: turn_manager not found, using local client as player two")
		return int(GDSync.get_client_id())

	return turn_manager.player_two_id
