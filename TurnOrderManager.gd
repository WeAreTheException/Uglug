extends Node
class_name TurnManager

signal attacking_first_changed(client_id: int)
signal turn_player_changed(client_id: int, phase_name: String)

@export var phase_manager: PhaseManager
@export var combat_manager: CombatManager

@export var draw_time: float = 15.0
@export var place_time: float = 60.0
@export var attack_time: float = 10.0

var player_one_id: int = -1
var player_two_id: int = -1

var current_first_id: int = -1
var current_second_id: int = -1

var auto_turns_running: bool = false

func _ready() -> void:
	GDSync.expose_node(self)

	GDSync.expose_func(receive_starting_players)
	GDSync.expose_func(receive_round_start)
	GDSync.expose_func(apply_step)

	GDSync.expose_func(request_start_auto_turns_from_client)
	GDSync.expose_func(request_flip_from_client)

	await get_tree().create_timer(1.0).timeout

	if GDSync.is_host():
		choose_starting_players()

func choose_starting_players() -> void:
	var clients := GDSync.lobby_get_all_clients()

	if clients.size() < 2:
		print("TurnManager blocked: need 2 clients")
		return

	player_one_id = int(GDSync.get_client_id())

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

	attacking_first_changed.emit(current_first_id)

	print("ATTACKING FIRST: ", current_first_id)

func request_start_auto_turns() -> void:
	if GDSync.is_host():
		start_auto_turns()
	else:
		GDSync.call_func(request_start_auto_turns_from_client)

func request_start_auto_turns_from_client() -> void:
	if not GDSync.is_host():
		return

	start_auto_turns()

func start_auto_turns() -> void:
	if auto_turns_running:
		return

	auto_turns_running = true
	run_auto_turn_loop()

func run_auto_turn_loop() -> void:
	while auto_turns_running:
		await run_one_round()

func run_one_round() -> void:
	# First player draws
	run_step(PhaseManager.Phase.DRAW, current_first_id)
	await get_tree().create_timer(draw_time).timeout

	# Second player draws
	run_step(PhaseManager.Phase.DRAW, current_second_id)
	await get_tree().create_timer(draw_time).timeout

	# First player places
	run_step(PhaseManager.Phase.PLACE, current_first_id)
	await get_tree().create_timer(place_time).timeout

	# Second player places
	run_step(PhaseManager.Phase.PLACE, current_second_id)
	await get_tree().create_timer(place_time).timeout

	# Attack phase
	run_step(PhaseManager.Phase.ATTACK, current_first_id)

	if combat_manager != null and not combat_manager.attack_round_running:
		combat_manager.start_attack_round()

	await get_tree().create_timer(attack_time).timeout

	flip_attacking_first()

func run_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	GDSync.call_func_all(apply_step, phase, active_player_id)

func apply_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	if phase_manager == null:
		return

	phase_manager.set_phase(phase, active_player_id)
	turn_player_changed.emit(active_player_id, phase_manager.get_phase_name())

func request_flip_attacking_first() -> void:
	if GDSync.is_host():
		flip_attacking_first()
	else:
		GDSync.call_func(request_flip_from_client)

func request_flip_from_client() -> void:
	if not GDSync.is_host():
		return

	flip_attacking_first()

func flip_attacking_first() -> void:
	var old_first := current_first_id
	current_first_id = current_second_id
	current_second_id = old_first

	GDSync.call_func_all(receive_round_start, current_first_id)
