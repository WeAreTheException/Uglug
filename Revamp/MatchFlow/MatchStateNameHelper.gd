extends RefCounted
class_name MatchStateNameHelper


func get_state_name(state: MatchFlowRoot.MatchState) -> String:
	match state:
		MatchFlowRoot.MatchState.NONE:
			return "NONE"

		MatchFlowRoot.MatchState.ROUND_INTRO:
			return "ROUND_INTRO"

		MatchFlowRoot.MatchState.AUTO_DRAW:
			return "AUTO_DRAW"

		MatchFlowRoot.MatchState.BLESSING:
			return "BLESSING"

		MatchFlowRoot.MatchState.BUFF:
			return "BUFF"

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			return "LEAD_PLACEMENT"

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			return "RESPONSE_PLACEMENT"

		MatchFlowRoot.MatchState.COMBAT:
			return "COMBAT"

		MatchFlowRoot.MatchState.DOMINANT_REVEAL:
			return "DOMINANT_REVEAL"

		MatchFlowRoot.MatchState.ROUND_END:
			return "ROUND_END"

		MatchFlowRoot.MatchState.GAME_END:
			return "GAME_END"

	return "UNKNOWN"
