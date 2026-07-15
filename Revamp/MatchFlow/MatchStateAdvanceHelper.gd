extends RefCounted
class_name MatchStateAdvanceHelper


func should_advance_round(state: MatchFlowRoot.MatchState) -> bool:
	return state == MatchFlowRoot.MatchState.ROUND_END


func get_next_state(
	state: MatchFlowRoot.MatchState,
	round_number: int
) -> MatchFlowRoot.MatchState:
	match state:
		MatchFlowRoot.MatchState.NONE:
			return MatchFlowRoot.MatchState.ROUND_INTRO

		MatchFlowRoot.MatchState.ROUND_INTRO:
			return MatchFlowRoot.MatchState.AUTO_DRAW

		MatchFlowRoot.MatchState.AUTO_DRAW:
			return MatchFlowRoot.MatchState.BUFF

		MatchFlowRoot.MatchState.BLESSING:
			return MatchFlowRoot.MatchState.LEAD_PLACEMENT

		MatchFlowRoot.MatchState.BUFF:
			return MatchFlowRoot.MatchState.LEAD_PLACEMENT

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			return MatchFlowRoot.MatchState.RESPONSE_PLACEMENT

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			return MatchFlowRoot.MatchState.COMBAT

		MatchFlowRoot.MatchState.COMBAT:
			return MatchFlowRoot.MatchState.ROUND_END

		MatchFlowRoot.MatchState.ROUND_END:
			return MatchFlowRoot.MatchState.ROUND_INTRO

		MatchFlowRoot.MatchState.GAME_END:
			return MatchFlowRoot.MatchState.GAME_END

	return state
