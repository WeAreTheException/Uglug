extends Node
class_name MatchPlacementFlowHandler

signal placement_flow_started(slot_owner: SlotRow.SlotOwner, is_response: bool)
signal placement_flow_finished(slot_owner: SlotRow.SlotOwner)

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState
@export var placement_controller: Node

@export var print_debug: bool = true

var is_active: bool = false
var active_slot_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var is_response_turn: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func begin_placement(
	slot_owner: SlotRow.SlotOwner,
	response_turn: bool
) -> void:
	is_active = true
	active_slot_owner = slot_owner
	is_response_turn = response_turn

	_notify_controller_begin()

	if print_debug:
		print(
			"PLACEMENT STARTED: ",
			_get_owner_name(active_slot_owner),
			" | RESPONSE: ",
			is_response_turn
		)

	placement_flow_started.emit(active_slot_owner, is_response_turn)


func end_placement() -> void:
	if not is_active:
		return

	var ended_owner: SlotRow.SlotOwner = active_slot_owner

	is_active = false
	_notify_controller_end()

	if print_debug:
		print("PLACEMENT FINISHED: ", _get_owner_name(ended_owner))

	placement_flow_finished.emit(ended_owner)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	match state:
		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			begin_placement(_get_lead_owner(), false)

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			begin_placement(_get_response_owner(), true)

		_:
			end_placement()


func _get_lead_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.lead_placement_owner


func _get_response_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.OPPONENT

	return turn_order_state.response_placement_owner


func _notify_controller_begin() -> void:
	if placement_controller == null:
		return

	if placement_controller.has_method("set_active_owner"):
		placement_controller.call("set_active_owner", active_slot_owner)

	if placement_controller.has_method("begin_match_placement"):
		placement_controller.call(
			"begin_match_placement",
			active_slot_owner,
			is_response_turn
		)


func _notify_controller_end() -> void:
	if placement_controller == null:
		return

	if placement_controller.has_method("end_match_placement"):
		placement_controller.call("end_match_placement")


func _get_owner_name(slot_owner: SlotRow.SlotOwner) -> String:
	match slot_owner:
		SlotRow.SlotOwner.PLAYER:
			return "P1"

		SlotRow.SlotOwner.OPPONENT:
			return "P2"

	return "UNKNOWN"
