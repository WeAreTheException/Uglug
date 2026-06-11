extends RefCounted
class_name MatchActiveOwnerResolverHelper


func apply_active_owner_for_state(
	state: MatchFlowRoot.MatchState,
	turn_order_state: MatchTurnOrderState
) -> void:
	if turn_order_state == null:
		return

	match state:
		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			turn_order_state.set_active_owner(
				turn_order_state.lead_placement_owner
			)

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			turn_order_state.set_active_owner(
				turn_order_state.response_placement_owner
			)

		MatchFlowRoot.MatchState.COMBAT:
			turn_order_state.set_active_owner(
				turn_order_state.attacking_first_owner
			)

		_:
			turn_order_state.set_active_owner(
				turn_order_state.attacking_first_owner
			)
