extends Control
class_name MatchUIRoot

@export var match_flow_root: MatchFlowRoot
@export var score_state: MatchScoreState

@export var tugga_display: TuggaBattleScaleDisplay


func _ready() -> void:
	_resolve_score_state()
	_setup_children()


func setup_match_context(source_match_flow_root: MatchFlowRoot) -> void:
	match_flow_root = source_match_flow_root
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
