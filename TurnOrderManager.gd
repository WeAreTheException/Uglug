extends Node
class_name TurnManager

signal attacking_first_changed(client_id: int)
signal turn_player_changed(client_id: int, phase_name: String)

@export var phase_manager: PhaseManager

var player_one_id: int = -1
var player_two_id: int = -1

var current_first_id: int = -1
var current_second_id: int = -1

func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(receive_starting_players)
	GDSync.expose_func(receive_round_start)
	GDSync.expose_func(apply_step)

	await get_tree().create_timer(1.0).timeout

	if GDSync.is_host():
		choose_starting_players()

func _unhandled_input(event: InputEvent) -> void:
	if not GDSync.is_host():
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				run_step(PhaseManager.Phase.DRAW, current_first_id)

			KEY_2:
				run_step(PhaseManager.Phase.PLACE, current_first_id)

			KEY_3:
				run_step(PhaseManager.Phase.ATTACK, current_first_id)

			KEY_4:
				debug_flip_attacking_first()

func choose_starting_players() -> void:
	var clients := GDSync.lobby_get_all_clients()
	if clients.size() < 2:
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var first_index := rng.randi_range(0, clients.size() - 1)
	player_one_id = int(clients[first_index])

	for id in clients:
		if int(id) != player_one_id:
			player_two_id = int(id)
			break

	GDSync.call_func_all(receive_starting_players, player_one_id, player_two_id)

func receive_starting_players(p1: int, p2: int) -> void:
	player_one_id = p1
	player_two_id = p2

	current_first_id = player_one_id
	current_second_id = player_two_id

	receive_round_start(current_first_id)

func receive_round_start(first_id: int) -> void:
	current_first_id = first_id

	if current_first_id == player_one_id:
		current_second_id = player_two_id
	else:
		current_second_id = player_one_id

	attacking_first_changed.emit(first_id)

func debug_flip_attacking_first() -> void:
	var old_first := current_first_id
	current_first_id = current_second_id
	current_second_id = old_first

	GDSync.call_func_all(receive_round_start, current_first_id)

func run_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	GDSync.call_func_all(apply_step, phase, active_player_id)

func apply_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	if phase_manager == null:
		return

	phase_manager.set_phase(phase)
	turn_player_changed.emit(active_player_id, phase_manager.get_phase_name())
