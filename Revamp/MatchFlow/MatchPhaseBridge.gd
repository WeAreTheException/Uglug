extends Node
class_name MatchPhaseBridge

@export var match_flow_root: MatchFlowRoot
@export var phase_manager: PhaseManager
@export var apply_current_state_on_ready: bool = true

@export var blessing_uses_buff_phase: bool = false
@export var dominant_reveal_uses_attack_phase: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)

	if apply_current_state_on_ready:
		apply_match_state(match_flow_root.current_state)


func apply_match_state(state: MatchFlowRoot.MatchState) -> void:
	if phase_manager == null:
		return

	phase_manager.set_phase(_get_phase_for_match_state(state))


func _get_phase_for_match_state(
	state: MatchFlowRoot.MatchState
) -> PhaseManager.Phase:
	match state:
		MatchFlowRoot.MatchState.ROUND_INTRO:
			return PhaseManager.Phase.DRAW

		MatchFlowRoot.MatchState.AUTO_DRAW:
			return PhaseManager.Phase.DRAW

		MatchFlowRoot.MatchState.BLESSING:
			if blessing_uses_buff_phase:
				return PhaseManager.Phase.BUFF

			return PhaseManager.Phase.DRAW

		MatchFlowRoot.MatchState.BUFF:
			return PhaseManager.Phase.BUFF

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			return PhaseManager.Phase.LEAD_PLAY

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			return PhaseManager.Phase.RESPONSE_PLAY

		MatchFlowRoot.MatchState.COMBAT:
			return PhaseManager.Phase.ATTACK

		MatchFlowRoot.MatchState.DOMINANT_REVEAL:
			if dominant_reveal_uses_attack_phase:
				return PhaseManager.Phase.ATTACK

			return PhaseManager.Phase.DRAW

		MatchFlowRoot.MatchState.ROUND_END:
			return PhaseManager.Phase.DRAW

	return PhaseManager.Phase.DRAW


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	apply_match_state(state)
