extends Node
class_name MatchPhaseTimer

signal timer_started(state: MatchFlowRoot.MatchState, duration: float)
signal timer_ticked(state: MatchFlowRoot.MatchState, remaining: float)
signal timer_finished(state: MatchFlowRoot.MatchState)

@export var match_flow_root: MatchFlowRoot

@export var blessing_seconds: float = 10.0
@export var buff_seconds: float = 10.0
@export var placement_seconds: float = 60.0
@export var tick_interval: float = 0.1

@export var print_debug: bool = true

var is_running: bool = false
var active_state: MatchFlowRoot.MatchState = MatchFlowRoot.MatchState.NONE
var remaining_seconds: float = 0.0
var timer_run_id: int = 0


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func start_for_state(state: MatchFlowRoot.MatchState) -> void:
	var duration := _get_duration_for_state(state)

	if duration <= 0.0:
		stop_timer()
		return

	stop_timer()

	timer_run_id += 1
	var local_run_id := timer_run_id

	active_state = state
	remaining_seconds = duration
	is_running = true

	if print_debug:
		print("PHASE TIMER STARTED: ", _get_state_name(state), " | ", duration)

	timer_started.emit(active_state, duration)
	_run_timer(local_run_id)


func stop_timer() -> void:
	timer_run_id += 1
	is_running = false
	active_state = MatchFlowRoot.MatchState.NONE
	remaining_seconds = 0.0


func get_remaining_seconds() -> float:
	return remaining_seconds


func _run_timer(local_run_id: int) -> void:
	while (
		is_running
		and local_run_id == timer_run_id
		and remaining_seconds > 0.0
	):
		timer_ticked.emit(active_state, remaining_seconds)
		await get_tree().create_timer(tick_interval).timeout

		if local_run_id != timer_run_id:
			return

		remaining_seconds -= tick_interval

	if local_run_id != timer_run_id:
		return

	if not is_running:
		return

	remaining_seconds = 0.0
	timer_ticked.emit(active_state, remaining_seconds)

	var finished_state := active_state
	stop_timer()

	if print_debug:
		print("PHASE TIMER FINISHED: ", _get_state_name(finished_state))

	timer_finished.emit(finished_state)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state != active_state:
		stop_timer()


func _get_duration_for_state(state: MatchFlowRoot.MatchState) -> float:
	match state:
		MatchFlowRoot.MatchState.BLESSING:
			return blessing_seconds

		MatchFlowRoot.MatchState.BUFF:
			return buff_seconds

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			return placement_seconds

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			return placement_seconds

	return 0.0


func _get_state_name(state: MatchFlowRoot.MatchState) -> String:
	if match_flow_root != null:
		return match_flow_root.get_state_name(state)

	return str(int(state))
