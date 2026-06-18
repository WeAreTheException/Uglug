extends Control
class_name AttackOrderArrowDisplay

@export var left_to_right_arrow: CanvasItem
@export var right_to_left_arrow: CanvasItem

@export var host_sees_left_to_right: bool = true
@export var client_sees_left_to_right: bool = false


func _ready() -> void:
	_refresh()


func setup(
	_source_slots_root: SlotsRoot,
	_source_turn_order_state: MatchTurnOrderState
) -> void:
	_refresh()


func refresh() -> void:
	_refresh()


func _refresh() -> void:
	var left_to_right := _get_left_to_right()

	if left_to_right_arrow != null:
		left_to_right_arrow.visible = left_to_right

	if right_to_left_arrow != null:
		right_to_left_arrow.visible = not left_to_right


func _get_left_to_right() -> bool:
	if GDSync.is_host():
		return host_sees_left_to_right

	return client_sees_left_to_right
