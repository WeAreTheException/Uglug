extends Node
class_name BuffFlowHandler

signal buff_started(round_number: int)
signal buff_finished(round_number: int)

@export var match_flow_root: MatchFlowRoot

@export var enable_debug_finish_key: bool = true
@export var debug_finish_key: Key = KEY_B
@export var print_debug: bool = true

var is_active: bool = false
var active_round_number: int = 0


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _input(event: InputEvent) -> void:
	if not enable_debug_finish_key:
		return

	if not is_active:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == debug_finish_key:
		finish_buff_flow()


func begin_buff_flow() -> void:
	if is_active:
		return

	if match_flow_root == null:
		return

	is_active = true
	active_round_number = match_flow_root.current_round
	match_flow_root.lock_transition()

	if print_debug:
		print("BUFF FLOW STARTED: ROUND ", active_round_number)

	buff_started.emit(active_round_number)


func finish_buff_flow() -> void:
	if not is_active:
		return

	is_active = false

	if match_flow_root != null:
		match_flow_root.unlock_transition()

	if print_debug:
		print("BUFF FLOW FINISHED: ROUND ", active_round_number)

	buff_finished.emit(active_round_number)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BUFF:
		begin_buff_flow()
		return

	if is_active:
		finish_buff_flow()
