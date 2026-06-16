extends Node
class_name MatchNetworkFlow

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func request_advance_match_state() -> void:
	if root == null:
		return

	if root.is_host():
		_process_advance_match_state_request()
		return

	GDSync.call_func(root.request_advance_match_state)


func receive_match_state_snapshot(payload: Dictionary) -> void:
	if root == null:
		return

	if root.match_flow_root == null:
		print("MATCH SNAPSHOT FAILED: match_flow_root missing")
		return

	root.match_flow_root.apply_network_snapshot(payload)


func _process_advance_match_state_request() -> void:
	if root.match_flow_root == null:
		print("MATCH ADVANCE REJECTED: match_flow_root missing")
		return

	var advanced := root.match_flow_root.host_advance_match_state()

	if not advanced:
		return

	_broadcast_match_state_snapshot()


func _broadcast_match_state_snapshot() -> void:
	var payload := root.match_flow_root.get_network_snapshot()

	GDSync.call_func_all(
		root._receive_match_state_snapshot,
		payload
	)
