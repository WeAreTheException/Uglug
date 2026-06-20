extends Node
class_name MatchNetworkDebugSync

@export var enable_snapshot_debug := true
@export var compare_snapshot_key: Key = KEY_F8
@export var print_full_snapshot_key: Key = KEY_F7

var root: MatchNetworkRoot = null
var builder := MatchSnapshotBuilder.new()
var comparer := MatchSnapshotComparer.new()


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func handle_debug_input(key_event: InputEventKey) -> void:
	if not enable_snapshot_debug:
		return

	if key_event.keycode == print_full_snapshot_key:
		print_local_snapshot()

	if key_event.keycode == compare_snapshot_key:
		request_snapshot_compare()


func print_local_snapshot() -> void:
	if root == null:
		return

	var snapshot := builder.build(root)
	print("MATCH SNAPSHOT LOCAL:")
	print(snapshot)


func request_snapshot_compare() -> void:
	if root == null:
		return

	if root.is_host():
		_host_send_snapshot_compare()
		return

	GDSync.call_func_on(1, root.request_debug_snapshot_compare)


func receive_snapshot_compare(host_snapshot: Dictionary) -> void:
	if root == null:
		return

	if root.is_host():
		return

	var local_snapshot := builder.build(root)
	comparer.compare(host_snapshot, local_snapshot)


func _host_send_snapshot_compare() -> void:
	if root == null:
		return

	if not root.is_host():
		return

	var snapshot := builder.build(root)

	print("HOST SNAPSHOT SENT FOR COMPARE")
	GDSync.call_func_all(root._receive_debug_snapshot_compare, snapshot)
