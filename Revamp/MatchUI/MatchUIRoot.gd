extends Control
class_name MatchUIRoot

@export var match_flow_root: MatchFlowRoot
@export var slots_root: SlotsRoot
@export var score_state: MatchScoreState

@export var tugga_display: TuggaBattleScaleDisplay
@export var attack_order_arrow_display: AttackOrderArrowDisplay


func _ready() -> void:
	_resolve_score_state()
	_setup_children()


func setup_match_context(
	source_match_flow_root: MatchFlowRoot,
	source_slots_root: SlotsRoot
) -> void:
	match_flow_root = source_match_flow_root
	slots_root = source_slots_root

	_resolve_score_state()
	_setup_children()


func _resolve_score_state() -> void:
	if score_state != null:
		return

	if match_flow_root == null:
		return

	score_state = match_flow_root.score_state


func _setup_children() -> void:
	if tugga_display != null:
		tugga_display.setup(score_state)

	if attack_order_arrow_display != null:
		attack_order_arrow_display.setup(
			slots_root,
			_get_turn_order_state()
		)


func _get_turn_order_state() -> MatchTurnOrderState:
	if match_flow_root == null:
		return null

	return match_flow_root.turn_order_state
