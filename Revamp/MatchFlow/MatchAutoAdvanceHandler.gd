extends Node
class_name MatchAutoAdvanceHandler

@export var match_flow_root: MatchFlowRoot
@export var match_network_root: MatchNetworkRoot

@export var auto_draw_handler: MatchAutoDrawHandler
@export var blessing_flow_handler: BlessingFlowHandler
@export var buff_flow_handler: BuffFlowHandler

@export var round_intro_delay: float = 0.75
@export var round_end_delay: float = 0.75
@export var enabled: bool = true
@export var print_debug: bool = true

var pending_advance_id: int = 0


func _ready() -> void:
	_connect_match_flow()
	_connect_auto_draw()
	_connect_blessing()
	_connect_buff()


func _connect_match_flow() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _connect_auto_draw() -> void:
	if auto_draw_handler == null:
		return

	if not auto_draw_handler.auto_draw_finished.is_connected(_on_auto_draw_finished):
		auto_draw_handler.auto_draw_finished.connect(_on_auto_draw_finished)


func _connect_blessing() -> void:
	if blessing_flow_handler == null:
		return

	if not blessing_flow_handler.blessing_finished.is_connected(_on_blessing_finished):
		blessing_flow_handler.blessing_finished.connect(_on_blessing_finished)


func _connect_buff() -> void:
	if buff_flow_handler == null:
		return

	if not buff_flow_handler.buff_finished.is_connected(_on_buff_finished):
		buff_flow_handler.buff_finished.connect(_on_buff_finished)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	pending_advance_id += 1

	if not _can_host_auto_advance():
		return

	match state:
		MatchFlowRoot.MatchState.ROUND_INTRO:
			_request_advance_after_delay(state, round_intro_delay)

		MatchFlowRoot.MatchState.ROUND_END:
			_request_advance_after_delay(state, round_end_delay)


func _on_auto_draw_finished(_round_number: int) -> void:
	_request_advance_if_state(MatchFlowRoot.MatchState.AUTO_DRAW)


func _on_blessing_finished() -> void:
	_request_advance_if_state(MatchFlowRoot.MatchState.BLESSING)


func _on_buff_finished(_round_number: int) -> void:
	_request_advance_if_state(MatchFlowRoot.MatchState.BUFF)


func _request_advance_after_delay(
	state: MatchFlowRoot.MatchState,
	delay: float
) -> void:
	var request_id := pending_advance_id

	if print_debug:
		print("AUTO ADVANCE WAIT: ", _get_state_name(state), " | ", delay)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	if request_id != pending_advance_id:
		return

	_request_advance_if_state(state)


func _request_advance_if_state(state: MatchFlowRoot.MatchState) -> void:
	if not _can_host_auto_advance():
		return

	if match_flow_root == null:
		return

	if match_flow_root.current_state != state:
		return

	if match_flow_root.is_transition_locked():
		if print_debug:
			print("AUTO ADVANCE BLOCKED: transition locked")
		return

	if print_debug:
		print("AUTO ADVANCE REQUEST: ", _get_state_name(state))

	match_network_root.request_advance_match_state()


func _can_host_auto_advance() -> bool:
	if not enabled:
		return false

	if match_network_root == null:
		return false

	return match_network_root.is_host()


func _get_state_name(state: MatchFlowRoot.MatchState) -> String:
	if match_flow_root != null:
		return match_flow_root.get_state_name(state)

	return str(int(state))
