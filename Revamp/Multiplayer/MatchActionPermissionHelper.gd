extends RefCounted
class_name MatchActionPermissionHelper


func can_local_owner_act(
	match_flow_root: MatchFlowRoot,
	turn_order_state: MatchTurnOrderState
) -> bool:
	if match_flow_root == null:
		return false

	if turn_order_state == null:
		return false

	if not _is_match_running(match_flow_root):
		return false

	if not _state_allows_input(match_flow_root):
		return false

	return turn_order_state.get_active_owner() == turn_order_state.get_controlled_owner()


func _is_match_running(match_flow_root: MatchFlowRoot) -> bool:
	if match_flow_root.has_method("is_match_running"):
		return match_flow_root.is_match_running()

	var state = match_flow_root.get("current_state")
	if state == null:
		return true

	return str(state) != "GAME_END"


func _state_allows_input(match_flow_root: MatchFlowRoot) -> bool:
	if match_flow_root.has_method("current_state_allows_input"):
		return match_flow_root.current_state_allows_input()

	var state_name := str(match_flow_root.get("current_state"))

	return state_name in [
		"BLESSING",
		"BUFF",
		"LEAD_PLACEMENT",
		"RESPONSE_PLACEMENT",
		"COMBAT"
	]
