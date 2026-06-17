extends Node
class_name BlessingFlowHandler

signal blessing_started
signal blessing_finished

@export var match_flow_root: MatchFlowRoot
@export var blessing_to_apply: Blessing
@export var blessing_animation_handler: BlessingAnimationHandler

@export var enable_debug_finish_key: bool = false
@export var debug_finish_key: Key = KEY_Y
@export var print_debug: bool = true

var is_active: bool = false
var is_waiting_for_outro: bool = false
var should_use_outro_on_finish: bool = true


func _ready() -> void:
	if match_flow_root != null:
		if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
			match_flow_root.match_state_changed.connect(_on_match_state_changed)

	if blessing_animation_handler != null:
		if not blessing_animation_handler.intro_finished.is_connected(_on_blessing_intro_finished):
			blessing_animation_handler.intro_finished.connect(_on_blessing_intro_finished)

		if not blessing_animation_handler.outro_finished.is_connected(_on_blessing_outro_finished):
			blessing_animation_handler.outro_finished.connect(_on_blessing_outro_finished)


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
		request_finish_blessing_flow()


func begin_blessing_flow() -> void:
	if is_active:
		return

	if match_flow_root == null:
		return

	if blessing_to_apply == null:
		print("BLESSING FLOW BLOCKED: blessing_to_apply missing")
		return

	is_active = true
	is_waiting_for_outro = false
	should_use_outro_on_finish = true

	match_flow_root.lock_transition()

	if print_debug:
		print("BLESSING FLOW STARTED")
		print("BLESSING REWARD: ", blessing_to_apply.get_display_name())

	if blessing_animation_handler != null:
		blessing_animation_handler.play_intro()
	else:
		_on_blessing_intro_finished()


func request_finish_blessing_flow() -> void:
	if not is_active:
		return

	if is_waiting_for_outro:
		return

	if should_use_outro_on_finish and blessing_animation_handler != null:
		is_waiting_for_outro = true
		blessing_animation_handler.play_outro()
		return

	finish_blessing_flow()


func finish_blessing_flow() -> void:
	if not is_active:
		return

	is_active = false
	is_waiting_for_outro = false

	if match_flow_root != null:
		match_flow_root.unlock_transition()

	if print_debug:
		print("BLESSING FLOW FINISHED")

	blessing_finished.emit()


func force_finish_blessing_flow() -> void:
	should_use_outro_on_finish = false
	finish_blessing_flow()


func get_active_blessing() -> Blessing:
	return blessing_to_apply


func _on_blessing_intro_finished() -> void:
	if not is_active:
		return

	if print_debug:
		print("BLESSING FLOW SELECTION ENABLED")

	blessing_started.emit()


func _on_blessing_outro_finished() -> void:
	if not is_active:
		return

	finish_blessing_flow()


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BLESSING:
		begin_blessing_flow()
		return

	if is_active:
		force_finish_blessing_flow()
