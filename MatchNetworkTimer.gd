extends Node
class_name MatchNetworkTimer

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root
	_connect_timer()


func _connect_timer() -> void:
	if root == null:
		return

	if not root.is_host():
		return

	if root.phase_timer == null:
		return

	if not root.phase_timer.timer_started.is_connected(_on_timer_started):
		root.phase_timer.timer_started.connect(_on_timer_started)

	if not root.phase_timer.timer_ticked.is_connected(_on_timer_ticked):
		root.phase_timer.timer_ticked.connect(_on_timer_ticked)

	if not root.phase_timer.timer_finished.is_connected(_on_timer_finished):
		root.phase_timer.timer_finished.connect(_on_timer_finished)


func _on_timer_started(
	state: MatchFlowRoot.MatchState,
	duration: float
) -> void:
	GDSync.call_func_all(root._receive_timer_started, int(state), duration)


func _on_timer_ticked(
	state: MatchFlowRoot.MatchState,
	remaining: float
) -> void:
	GDSync.call_func_all(root._receive_timer_ticked, int(state), remaining)


func _on_timer_finished(state: MatchFlowRoot.MatchState) -> void:
	GDSync.call_func_all(root._receive_timer_finished, int(state))


func receive_timer_started(
	state_value: int,
	duration: float
) -> void:
	if root == null:
		return

	if root.is_host():
		return

	if root.phase_timer == null:
		return

	root.phase_timer.apply_network_timer_started(
		state_value as MatchFlowRoot.MatchState,
		duration
	)


func receive_timer_ticked(
	state_value: int,
	remaining: float
) -> void:
	if root == null:
		return

	if root.is_host():
		return

	if root.phase_timer == null:
		return

	root.phase_timer.apply_network_timer_ticked(
		state_value as MatchFlowRoot.MatchState,
		remaining
	)


func receive_timer_finished(state_value: int) -> void:
	if root == null:
		return

	if root.is_host():
		return

	if root.phase_timer == null:
		return

	root.phase_timer.apply_network_timer_finished(
		state_value as MatchFlowRoot.MatchState
	)
