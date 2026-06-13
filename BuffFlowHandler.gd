extends Node
class_name BuffFlowHandler

signal buff_started(round_number: int)
signal buff_finished(round_number: int)
signal reward_generated(mutation: Mutation)

@export var match_flow_root: MatchFlowRoot
@export var buff_database: BuffDatabase

@export var enable_debug_finish_key: bool = true
@export var debug_finish_key: Key = KEY_B
@export var print_debug: bool = true

var is_active: bool = false
var active_round_number: int = 0
var active_reward_mutation: Mutation = null


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

	active_reward_mutation = _generate_reward_mutation()

	if active_reward_mutation == null:
		print("BUFF FLOW BLOCKED: no reward mutation")
		return

	is_active = true
	active_round_number = match_flow_root.current_round
	match_flow_root.lock_transition()

	if print_debug:
		print("BUFF FLOW STARTED: ROUND ", active_round_number)
		print("BUFF REWARD: ", active_reward_mutation.mutation_name)

	buff_started.emit(active_round_number)
	reward_generated.emit(active_reward_mutation)


func finish_buff_flow() -> void:
	if not is_active:
		return

	is_active = false

	if match_flow_root != null:
		match_flow_root.unlock_transition()

	if print_debug:
		print("BUFF FLOW FINISHED: ROUND ", active_round_number)

	buff_finished.emit(active_round_number)

	active_round_number = 0
	active_reward_mutation = null


func get_active_reward_mutation() -> Mutation:
	return active_reward_mutation


func _generate_reward_mutation() -> Mutation:
	if buff_database == null:
		print("BUFF FLOW BLOCKED: buff_database missing")
		return null

	if not buff_database.has_available_mutations():
		print("BUFF FLOW BLOCKED: buff database empty")
		return null

	print("BuffDatabase count before draw: ", buff_database.get_remaining_count())

	var mutation := buff_database.draw_random_mutation()

	print("BuffDatabase count after draw: ", buff_database.get_remaining_count())

	return mutation


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BUFF:
		begin_buff_flow()
		return

	if is_active:
		finish_buff_flow()
