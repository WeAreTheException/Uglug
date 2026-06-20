extends Node
class_name MatchNetworkDebugSync

@export var enable_snapshot_debug := true
@export var print_full_snapshot_key: Key = KEY_7
@export var compare_snapshot_key: Key = KEY_8
@export var preview_resync_key: Key = KEY_9

var root: MatchNetworkRoot = null
var builder := MatchSnapshotBuilder.new()
var comparer := MatchSnapshotComparer.new()
var resync := MatchSnapshotResync.new()


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func handle_debug_input(key_event: InputEventKey) -> void:
	if not enable_snapshot_debug:
		return

	if key_event.keycode == print_full_snapshot_key:
		print_local_snapshot()

	if key_event.keycode == compare_snapshot_key:
		request_snapshot_compare()

	if key_event.keycode == preview_resync_key:
		request_resync_preview()


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


func request_resync_preview() -> void:
	if root == null:
		return

	if root.is_host():
		_host_send_resync_preview()
		return

	GDSync.call_func_on(1, root.request_debug_resync_preview)


func receive_resync_preview(host_snapshot: Dictionary) -> void:
	if root == null:
		return

	if root.is_host():
		return

	resync.preview_resync(root, host_snapshot)


func _host_send_snapshot_compare() -> void:
	if root == null:
		return

	if not root.is_host():
		return

	var snapshot := builder.build(root)

	print("HOST SNAPSHOT SENT FOR COMPARE")
	GDSync.call_func_all(root._receive_debug_snapshot_compare, snapshot)


func _host_send_resync_preview() -> void:
	if root == null:
		return

	if not root.is_host():
		return

	var snapshot := builder.build(root)

	print("HOST SNAPSHOT SENT FOR RESYNC PREVIEW")
	GDSync.call_func_all(root._receive_debug_resync_preview, snapshot)
