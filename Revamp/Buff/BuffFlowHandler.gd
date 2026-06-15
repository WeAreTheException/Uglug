extends Node
class_name BuffFlowHandler

signal buff_started(round_number: int)
signal buff_finished(round_number: int)
signal reward_generated(mutation: Mutation)

@export var match_flow_root: MatchFlowRoot
@export var buff_database: BuffDatabase
@export var animation_handler: BuffPhaseAnimationHandler

@export_group("Debug")
@export var enable_debug_finish_key: bool = true
@export var debug_finish_key: Key = KEY_B
@export var enable_debug_preview_key: bool = true
@export var debug_preview_key: Key = KEY_L
@export var debug_preview_mutation: Mutation
@export var enable_debug_forced_reward_key := false
@export var debug_forced_reward_key: Key = KEY_K
@export var debug_forced_reward_id := "spiky"
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
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if enable_debug_finish_key and is_active:
		if key_event.keycode == debug_finish_key:
			finish_buff_flow()

	if enable_debug_preview_key:
		if key_event.keycode == debug_preview_key:
			debug_preview_reward_animation()

	if enable_debug_forced_reward_key:
		if key_event.keycode == debug_forced_reward_key:
			debug_start_forced_reward()


func begin_buff_flow_with_reward(mutation: Mutation) -> void:
	if is_active:
		return

	if match_flow_root == null:
		return

	if mutation == null:
		print("BUFF FLOW BLOCKED: forced reward missing")
		return

	active_reward_mutation = mutation
	is_active = true
	active_round_number = match_flow_root.current_round
	match_flow_root.lock_transition()

	if print_debug:
		print("BUFF FLOW STARTED: ROUND ", active_round_number)
		print("BUFF REWARD: ", active_reward_mutation.mutation_name)

	buff_started.emit(active_round_number)
	reward_generated.emit(active_reward_mutation)

	if animation_handler != null:
		await animation_handler.play_reward_delivery(active_reward_mutation)


func finish_buff_flow() -> void:
	if not is_active:
		return

	is_active = false

	if animation_handler != null:
		animation_handler.cleanup()

	if match_flow_root != null:
		match_flow_root.unlock_transition()

	if print_debug:
		print("BUFF FLOW FINISHED: ROUND ", active_round_number)

	buff_finished.emit(active_round_number)

	active_round_number = 0
	active_reward_mutation = null


func debug_preview_reward_animation() -> void:
	var mutation := debug_preview_mutation

	if mutation == null:
		mutation = active_reward_mutation

	if mutation == null:
		print("BUFF DEBUG PREVIEW BLOCKED: no mutation assigned")
		return

	if animation_handler == null:
		print("BUFF DEBUG PREVIEW BLOCKED: animation_handler missing")
		return

	await animation_handler.play_reward_delivery(mutation)


func debug_start_forced_reward() -> void:
	if buff_database == null:
		print("BUFF DEBUG FORCED BLOCKED: buff_database missing")
		return

	var mutation := buff_database.get_mutation_by_id(debug_forced_reward_id)
	begin_buff_flow_with_reward(mutation)


func get_active_reward_mutation() -> Mutation:
	return active_reward_mutation


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BUFF:
		return

	if is_active:
		finish_buff_flow()
