extends Node
class_name MatchAutoDrawHandler

signal auto_draw_started(round_number: int)
signal auto_draw_finished(round_number: int)

@export var match_flow_root: MatchFlowRoot
@export var match_network_root: MatchNetworkRoot
@export var match_phase_timer: MatchPhaseTimer

@export var max_draws_per_owner: int = 2
@export var card_draw_delay: float = 0.12
@export var print_debug: bool = true

var drawn_rounds: Array[int] = []
var draw_counts: Dictionary = {}

var active_round: int = 0
var is_finishing: bool = false
var transition_locked: bool = false


func _ready() -> void:
	_reset_draw_counts()

	if match_flow_root != null:
		if not match_flow_root.match_state_changed.is_connected(
			_on_match_state_changed
		):
			match_flow_root.match_state_changed.connect(
				_on_match_state_changed
			)

	if match_phase_timer != null:
		if not match_phase_timer.timer_finished.is_connected(
			_on_timer_finished
		):
			match_phase_timer.timer_finished.connect(
				_on_timer_finished
			)

	call_deferred("_connect_draw_network")

	if (
		match_flow_root != null
		and match_flow_root.current_state
		== MatchFlowRoot.MatchState.AUTO_DRAW
	):
		call_deferred("_begin_draw_phase")


func _connect_draw_network() -> void:
	if match_network_root == null:
		print(
			"AUTO DRAW BLOCKED: MatchNetworkRoot missing"
		)
		return

	if match_network_root.draw_network == null:
		print(
			"AUTO DRAW BLOCKED: MatchNetworkDraw missing"
		)
		return

	if not match_network_root.draw_network.confirmed_draw_applied.is_connected(
		_on_confirmed_draw_applied
	):
		match_network_root.draw_network.confirmed_draw_applied.connect(
			_on_confirmed_draw_applied
		)


func _on_match_state_changed(
	state: MatchFlowRoot.MatchState
) -> void:
	if state == MatchFlowRoot.MatchState.AUTO_DRAW:
		_begin_draw_phase()
		return

	_end_draw_phase_state()


func _begin_draw_phase() -> void:
	if match_flow_root == null:
		return

	var round_number: int = (
		match_flow_root.current_round
	)

	if drawn_rounds.has(round_number):
		return

	drawn_rounds.append(round_number)

	active_round = round_number
	is_finishing = false
	transition_locked = false

	_reset_draw_counts()

	if _is_host():
		match_flow_root.lock_transition()
		transition_locked = true

		if match_phase_timer != null:
			match_phase_timer.start_for_state(
				MatchFlowRoot.MatchState.AUTO_DRAW
			)
		else:
			print(
				"DRAW TIMER BLOCKED: "
				+ "MatchPhaseTimer missing"
			)

	if print_debug:
		print(
			"MANUAL DRAW PHASE STARTED: ROUND ",
			active_round
		)

	auto_draw_started.emit(active_round)


func _on_confirmed_draw_applied(
	owner: SlotRow.SlotOwner,
	_card: CardRoot,
	pile_type: String
) -> void:
	if not _is_draw_phase():
		return

	if (
		pile_type
		!= DeckSystemRoot.DRAW_PILE_WARRIOR
		and pile_type
		!= DeckSystemRoot.DRAW_PILE_WORKER
	):
		return

	var owner_key: int = int(owner)

	var current_count: int = int(
		draw_counts.get(
			owner_key,
			0
		)
	)

	draw_counts[owner_key] = mini(
		current_count + 1,
		max_draws_per_owner
	)

	if print_debug:
		print(
			"DRAW CONFIRMED COUNT: ",
			_get_owner_name(owner),
			" ",
			draw_counts[owner_key],
			"/",
			max_draws_per_owner
		)

	if not _is_host():
		return

	if is_finishing:
		return

	if _both_owners_finished():
		call_deferred("_finish_draw_early")


func _finish_draw_early() -> void:
	if not _is_host():
		return

	if not _is_draw_phase():
		return

	if is_finishing:
		return

	is_finishing = true

	if match_phase_timer != null:
		match_phase_timer.stop_timer()

	if print_debug:
		print(
			"MANUAL DRAW COMPLETED EARLY: ROUND ",
			active_round
		)

	_finish_draw_phase()


func _on_timer_finished(
	state: MatchFlowRoot.MatchState
) -> void:
	if state != MatchFlowRoot.MatchState.AUTO_DRAW:
		return

	if not _is_host():
		return

	if not _is_draw_phase():
		return

	if is_finishing:
		return

	_resolve_missing_draws()


func _resolve_missing_draws() -> void:
	is_finishing = true

	if print_debug:
		print(
			"DRAW TIMER FINISHED: "
			+ "FILLING MISSING CARDS"
		)

	await _fill_missing_for_owner(
		SlotRow.SlotOwner.PLAYER
	)

	await _fill_missing_for_owner(
		SlotRow.SlotOwner.OPPONENT
	)

	if card_draw_delay > 0.0:
		await get_tree().create_timer(
			card_draw_delay
		).timeout

	_finish_draw_phase()


func _fill_missing_for_owner(
	owner: SlotRow.SlotOwner
) -> void:
	var current_count: int = (
		_get_draw_count(owner)
	)

	var missing_count: int = maxi(
		max_draws_per_owner - current_count,
		0
	)

	if missing_count <= 0:
		return

	# No manual selections:
	# automatically give one Warrior first.
	if current_count == 0:
		_request_draw(
			owner,
			DeckSystemRoot.DRAW_PILE_WARRIOR
		)

		missing_count -= 1

		if card_draw_delay > 0.0:
			await get_tree().create_timer(
				card_draw_delay
			).timeout

	# Any remaining missing card is a Worker.
	while missing_count > 0:
		_request_draw(
			owner,
			DeckSystemRoot.DRAW_PILE_WORKER
		)

		missing_count -= 1

		if card_draw_delay > 0.0:
			await get_tree().create_timer(
				card_draw_delay
			).timeout


func _request_draw(
	owner: SlotRow.SlotOwner,
	pile_type: String
) -> void:
	if match_network_root == null:
		return

	match_network_root.request_draw(
		owner,
		pile_type
	)


func _finish_draw_phase() -> void:
	if transition_locked:
		if match_flow_root != null:
			match_flow_root.unlock_transition()

	transition_locked = false

	if print_debug:
		print(
			"MANUAL DRAW PHASE FINISHED: ROUND ",
			active_round
		)

	auto_draw_finished.emit(active_round)


func _end_draw_phase_state() -> void:
	if transition_locked:
		if match_flow_root != null:
			match_flow_root.unlock_transition()

	transition_locked = false
	is_finishing = false


func _both_owners_finished() -> bool:
	return (
		_get_draw_count(
			SlotRow.SlotOwner.PLAYER
		) >= max_draws_per_owner
		and
		_get_draw_count(
			SlotRow.SlotOwner.OPPONENT
		) >= max_draws_per_owner
	)


func _get_draw_count(
	owner: SlotRow.SlotOwner
) -> int:
	return int(
		draw_counts.get(
			int(owner),
			0
		)
	)


func _reset_draw_counts() -> void:
	draw_counts = {
		int(SlotRow.SlotOwner.PLAYER): 0,
		int(SlotRow.SlotOwner.OPPONENT): 0
	}


func _is_draw_phase() -> bool:
	if match_flow_root == null:
		return false

	return (
		match_flow_root.current_state
		== MatchFlowRoot.MatchState.AUTO_DRAW
	)


func _is_host() -> bool:
	if match_network_root == null:
		return false

	return match_network_root.is_host()


func _get_owner_name(
	owner: SlotRow.SlotOwner
) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
