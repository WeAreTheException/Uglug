extends Node
class_name TurnManager

signal turn_player_changed(client_id: int, phase_name: String)

@export var phase_manager: PhaseManager
@export var step_seconds: float = 1.0

var first_player_id: int = -1
var second_player_id: int = -1
var round_starter_id: int = -1
var other_player_id: int = -1

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout

	if GDSync.is_host():
		choose_starting_player()

func choose_starting_player() -> void:
	var clients := GDSync.lobby_get_all_clients()
	if clients.size() < 2:
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var first_index := rng.randi_range(0, clients.size() - 1)
	first_player_id = int(clients[first_index])

	for id in clients:
		if int(id) != first_player_id:
			second_player_id = int(id)
			break

	GDSync.expose_node(self)
	GDSync.expose_func(receive_starting_players)
	GDSync.call_func_all(receive_starting_players, first_player_id, second_player_id)

func receive_starting_players(p1: int, p2: int) -> void:
	first_player_id = p1
	second_player_id = p2

	round_starter_id = first_player_id
	other_player_id = second_player_id

	if GDSync.is_host():
		run_turn_loop()

func run_turn_loop() -> void:
	while true:
		await run_round(round_starter_id, other_player_id)

		var old_starter := round_starter_id
		round_starter_id = other_player_id
		other_player_id = old_starter

func run_round(starter_id: int, follower_id: int) -> void:
	run_step(PhaseManager.Phase.DRAW, starter_id)
	await get_tree().create_timer(step_seconds).timeout

	run_step(PhaseManager.Phase.DRAW, follower_id)
	await get_tree().create_timer(step_seconds).timeout

	run_step(PhaseManager.Phase.PLACE, starter_id)
	await get_tree().create_timer(step_seconds).timeout

	run_step(PhaseManager.Phase.PLACE, follower_id)
	await get_tree().create_timer(step_seconds).timeout

	run_step(PhaseManager.Phase.ATTACK, starter_id)
	await get_tree().create_timer(step_seconds).timeout

	run_step(PhaseManager.Phase.ATTACK, follower_id)
	await get_tree().create_timer(step_seconds).timeout

func run_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	GDSync.call_func_all(apply_step, phase, active_player_id)

func apply_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	if phase_manager != null:
		phase_manager.set_phase(phase)

	var phase_name := ""
	if phase_manager != null:
		phase_name = phase_manager.get_phase_name()

	turn_player_changed.emit(active_player_id, phase_name)

func is_my_turn() -> bool:
	return false
