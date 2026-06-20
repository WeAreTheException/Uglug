extends Node
class_name MatchPlacementCompletionHandler

@export var match_flow_root: MatchFlowRoot
@export var match_network_root: MatchNetworkRoot
@export var turn_order_state: MatchTurnOrderState
@export var phase_timer: MatchPhaseTimer

@export var print_debug: bool = true

var is_active: bool = false
var active_state: MatchFlowRoot.MatchState = MatchFlowRoot.MatchState.NONE
var active_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var has_requested_finish: bool = false
var end_turn_button: BaseButton = null


func _ready() -> void:
	_connect_match_flow()
	_connect_timer()
	_connect_button()
	_update_button_visible(false)


func request_end_turn() -> void:
	if not is_active:
		return

	if has_requested_finish:
		return

	if not _is_local_active_owner():
		if print_debug:
			print("END TURN BLOCKED: not local active owner")
		return

	has_requested_finish = true

	if print_debug:
		print(
			"END TURN REQUESTED: ",
			_get_state_name(active_state),
			" | OWNER: ",
			_get_owner_name(active_owner)
		)

	_request_host_advance()


func _connect_match_flow() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _connect_timer() -> void:
	if phase_timer == null:
		return

	if not phase_timer.timer_finished.is_connected(_on_timer_finished):
		phase_timer.timer_finished.connect(_on_timer_finished)


func _connect_button() -> void:
	if end_turn_button == null:
		return

	if not end_turn_button.pressed.is_connected(_on_end_turn_pressed):
		end_turn_button.pressed.connect(_on_end_turn_pressed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if _is_placement_state(state):
		_begin_placement_state(state)
		return

	_end_placement_state()


func _begin_placement_state(state: MatchFlowRoot.MatchState) -> void:
	is_active = true
	active_state = state
	has_requested_finish = false
	active_owner = _get_active_owner_for_state(state)

	if phase_timer != null:
		if match_network_root == null or match_network_root.is_host():
			phase_timer.start_for_state(state)

	_update_button_visible(_is_local_active_owner())

	if print_debug:
		print(
			"PLACEMENT COMPLETION STARTED: ",
			_get_state_name(active_state),
			" | OWNER: ",
			_get_owner_name(active_owner)
		)


func _end_placement_state() -> void:
	if not is_active:
		return

	is_active = false
	has_requested_finish = false
	active_state = MatchFlowRoot.MatchState.NONE

	if phase_timer != null:
		phase_timer.stop_timer()

	_update_button_visible(false)


func _on_timer_finished(state: MatchFlowRoot.MatchState) -> void:
	if not is_active:
		return

	if state != active_state:
		return

	if has_requested_finish:
		return

	if match_network_root == null:
		return

	if not match_network_root.is_host():
		return

	has_requested_finish = true

	if print_debug:
		print("PLACEMENT TIMER EXPIRED: ", _get_state_name(state))

	_request_host_advance()


func _on_end_turn_pressed() -> void:
	request_end_turn()


func _request_host_advance() -> void:
	if match_network_root != null:
		match_network_root.request_advance_match_state()
		return

	if match_flow_root != null:
		match_flow_root.host_advance_match_state()


func _is_placement_state(state: MatchFlowRoot.MatchState) -> bool:
	return (
		state == MatchFlowRoot.MatchState.LEAD_PLACEMENT
		or state == MatchFlowRoot.MatchState.RESPONSE_PLACEMENT
	)


func _get_active_owner_for_state(state: MatchFlowRoot.MatchState) -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	if state == MatchFlowRoot.MatchState.LEAD_PLACEMENT:
		return turn_order_state.lead_placement_owner

	if state == MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
		return turn_order_state.response_placement_owner

	return turn_order_state.active_owner


func _is_local_active_owner() -> bool:
	if match_network_root == null:
		return true

	return match_network_root.get_local_owner() == active_owner


func _update_button_visible(value: bool) -> void:
	if end_turn_button == null:
		return

	end_turn_button.visible = value
	end_turn_button.disabled = not value


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if turn_order_state != null:
		return turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"


func _get_state_name(state: MatchFlowRoot.MatchState) -> String:
	if match_flow_root != null:
		return match_flow_root.get_state_name(state)

	return str(int(state))


func setup_end_turn_button(button: BaseButton) -> void:
	end_turn_button = button
	_connect_button()
	_update_button_visible(false)
