extends Control
class_name AttackOrderArrowDisplay

@export var left_to_right_arrow: CanvasItem
@export var right_to_left_arrow: CanvasItem

@export var use_controlled_owner: bool = true
@export var fallback_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER

var slots_root: SlotsRoot = null
var turn_order_state: MatchTurnOrderState = null


func _ready() -> void:
	_refresh()


func setup(
	source_slots_root: SlotsRoot,
	source_turn_order_state: MatchTurnOrderState
) -> void:
	slots_root = source_slots_root
	turn_order_state = source_turn_order_state

	_connect_turn_order_state()
	_refresh()


func refresh() -> void:
	_refresh()


func _connect_turn_order_state() -> void:
	if turn_order_state == null:
		return

	if not turn_order_state.controlled_owner_changed.is_connected(_on_owner_changed):
		turn_order_state.controlled_owner_changed.connect(_on_owner_changed)

	if not turn_order_state.active_owner_changed.is_connected(_on_owner_changed):
		turn_order_state.active_owner_changed.connect(_on_owner_changed)


func _on_owner_changed(_owner: SlotRow.SlotOwner) -> void:
	_refresh()


func _refresh() -> void:
	var left_to_right := _get_left_to_right()

	if left_to_right_arrow != null:
		left_to_right_arrow.visible = left_to_right

	if right_to_left_arrow != null:
		right_to_left_arrow.visible = not left_to_right


func _get_left_to_right() -> bool:
	if slots_root == null:
		return true

	if slots_root.attack_order_handler == null:
		return true

	return slots_root.attack_order_handler.get_left_to_right(_get_owner())


func _get_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return fallback_owner

	if use_controlled_owner:
		return turn_order_state.controlled_owner

	return turn_order_state.active_owner
