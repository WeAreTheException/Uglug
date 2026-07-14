extends Node
class_name MatchFlowBoardApplier

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState
@export var slots_root: SlotsRoot
@export var match_network_root: MatchNetworkRoot

@export var apply_current_state_on_ready := true


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)

	if apply_current_state_on_ready:
		apply_state(match_flow_root.current_state)


func apply_state(state: MatchFlowRoot.MatchState) -> void:
	if slots_root == null:
		return

	match state:
		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			_show_local_playable_slots_if_active()

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			_show_local_playable_slots_if_active()

		_:
			slots_root.show_neutral_slots()


func _show_local_playable_slots_if_active() -> void:
	var active_owner := _get_active_owner()
	var local_owner := _get_local_owner()

	if active_owner != local_owner:
		slots_root.show_neutral_slots()
		return

	slots_root.show_playable_slots(SlotRow.SlotOwner.PLAYER)


func _get_active_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.get_active_owner()


func _get_local_owner() -> SlotRow.SlotOwner:
	if match_network_root == null:
		return SlotRow.SlotOwner.PLAYER

	return match_network_root.get_local_owner()


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	apply_state(state)
