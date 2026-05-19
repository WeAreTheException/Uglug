extends Node
class_name TurnManager

signal attacking_first_changed(client_id: int)
signal turn_player_changed(client_id: int, phase_name: String)

@export var phase_manager: PhaseManager
@export var combat_manager: CombatManager
@export var round_manager: RoundManager

var player_one_id: int = -1
var player_two_id: int = -1

var current_first_id: int = -1
var current_second_id: int = -1

var current_placing_player_id: int = -1
var attack_flow_running: bool = false

func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(receive_starting_players)
	GDSync.expose_func(receive_round_start)
	GDSync.expose_func(apply_step)
	GDSync.expose_func(apply_placing_player)
	GDSync.expose_func(request_step_from_client)
	GDSync.expose_func(request_start_place_from_client)
	GDSync.expose_func(request_done_placing_from_client)
	GDSync.expose_func(request_flip_from_client)

	await get_tree().create_timer(1.0).timeout

	if GDSync.is_host():
		choose_starting_players()

func choose_starting_players() -> void:
	var clients := GDSync.lobby_get_all_clients()

	if clients.size() < 2:
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

	if GDSync.is_host():
		await get_tree().process_frame
		await get_tree().process_frame

		var game_start_draw_handler := get_node_or_null("../GameStartDrawHandler")
		if game_start_draw_handler != null:
			game_start_draw_handler.give_starting_cards()

		start_place_phase()

func receive_round_start(first_id: int) -> void:
	current_first_id = first_id

	if current_first_id == player_one_id:
		current_second_id = player_two_id
	else:
		current_second_id = player_one_id

	attacking_first_changed.emit(first_id)

func request_step(phase: PhaseManager.Phase) -> void:
	if GDSync.is_host():
		run_step(phase, current_first_id)
	else:
		GDSync.call_func(request_step_from_client, phase)

func request_step_from_client(phase: PhaseManager.Phase) -> void:
	if not GDSync.is_host():
		return

	run_step(phase, current_first_id)

func request_start_place_phase() -> void:
	if GDSync.is_host():
		start_place_phase()
	else:
		GDSync.call_func(request_start_place_from_client)

func request_start_place_from_client() -> void:
	if not GDSync.is_host():
		return

	start_place_phase()

func start_place_phase() -> void:
	current_placing_player_id = current_first_id

	GDSync.call_func_all(apply_step, PhaseManager.Phase.PLACE, current_placing_player_id)
	GDSync.call_func_all(apply_placing_player, current_placing_player_id)

func request_done_placing() -> void:
	if GDSync.is_host():
		done_placing(int(GDSync.get_client_id()))
	else:
		GDSync.call_func(request_done_placing_from_client, int(GDSync.get_client_id()))

func request_done_placing_from_client(client_id: int) -> void:
	if not GDSync.is_host():
		return

	done_placing(client_id)

func force_done_current_placing_player() -> void:
	if not GDSync.is_host():
		return

	if current_placing_player_id == -1:
		return

	done_placing(current_placing_player_id)

func done_placing(client_id: int) -> void:
	if phase_manager == null:
		return

	if not phase_manager.is_place_phase():
		return

	if client_id != current_placing_player_id:
		print("done placing blocked: not your placement turn")
		return

	if current_placing_player_id == current_first_id:
		current_placing_player_id = current_second_id
		GDSync.call_func_all(apply_placing_player, current_placing_player_id)
		return

	current_placing_player_id = -1
	GDSync.call_func_all(apply_placing_player, current_placing_player_id)

	run_step(PhaseManager.Phase.ATTACK, current_first_id)

func apply_placing_player(client_id: int) -> void:
	current_placing_player_id = client_id
	turn_player_changed.emit(client_id, "Place")

	print("CURRENT PLACING PLAYER: ", current_placing_player_id)

	if phase_manager == null:
		return

	if current_placing_player_id == -1:
		phase_manager.stop_place_timer()
		return

	var is_player_one_turn := current_placing_player_id == current_first_id
	phase_manager.start_place_timer(is_player_one_turn)

func can_local_player_place() -> bool:
	if phase_manager == null:
		return false

	if not phase_manager.is_place_phase():
		return false

	return int(GDSync.get_client_id()) == current_placing_player_id

func request_flip_attacking_first() -> void:
	if GDSync.is_host():
		debug_flip_attacking_first()
	else:
		GDSync.call_func(request_flip_from_client)

func request_flip_from_client() -> void:
	if not GDSync.is_host():
		return

	debug_flip_attacking_first()

func debug_flip_attacking_first() -> void:
	var old_first := current_first_id
	current_first_id = current_second_id
	current_second_id = old_first

	GDSync.call_func_all(receive_round_start, current_first_id)

func run_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	if phase != PhaseManager.Phase.PLACE:
		current_placing_player_id = -1
		GDSync.call_func_all(apply_placing_player, current_placing_player_id)

	GDSync.call_func_all(apply_step, phase, active_player_id)

	if phase != PhaseManager.Phase.ATTACK:
		return

	if not GDSync.is_host():
		return

	start_attack_flow()

func start_attack_flow() -> void:
	if attack_flow_running:
		return

	attack_flow_running = true
	_run_attack_flow()

func _run_attack_flow() -> void:
	if combat_manager != null:
		if not combat_manager.attack_round_running:
			combat_manager.start_attack_round()

		while combat_manager.attack_round_running:
			await get_tree().process_frame

	if phase_manager != null:
		await phase_manager.wait_attack_timer()

	attack_flow_running = false

	flip_attack_order_after_round()

	if round_manager != null:
		round_manager.advance_round()

	run_step(PhaseManager.Phase.DRAW, current_first_id)

func flip_attack_order_after_round() -> void:
	var old_first := current_first_id
	current_first_id = current_second_id
	current_second_id = old_first

	GDSync.call_func_all(receive_round_start, current_first_id)

func apply_step(phase: PhaseManager.Phase, active_player_id: int) -> void:
	if phase_manager == null:
		return

	phase_manager.set_phase(phase)
	turn_player_changed.emit(active_player_id, phase_manager.get_phase_name())
