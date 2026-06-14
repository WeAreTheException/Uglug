extends Node
class_name BlessingFlowHandler

signal blessing_started
signal blessing_finished

@export var match_flow_root: MatchFlowRoot
@export var blessing_to_apply: Blessing

@export var enable_debug_finish_key: bool = false
@export var debug_finish_key: Key = KEY_Y
@export var print_debug: bool = true

var is_active: bool = false


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
		finish_blessing_flow()


func begin_blessing_flow() -> void:
	if is_active:
		return

	if match_flow_root == null:
		return

	if blessing_to_apply == null:
		print("BLESSING FLOW BLOCKED: blessing_to_apply missing")
		return

	is_active = true
	match_flow_root.lock_transition()

	if print_debug:
		print("BLESSING FLOW STARTED")
		print("BLESSING REWARD: ", blessing_to_apply.get_display_name())

	blessing_started.emit()


func finish_blessing_flow() -> void:
	if not is_active:
		return

	is_active = false

	if match_flow_root != null:
		match_flow_root.unlock_transition()

	if print_debug:
		print("BLESSING FLOW FINISHED")

	blessing_finished.emit()


func get_active_blessing() -> Blessing:
	return blessing_to_apply


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BLESSING:
		begin_blessing_flow()
		return

	if is_active:
		finish_blessing_flow()
