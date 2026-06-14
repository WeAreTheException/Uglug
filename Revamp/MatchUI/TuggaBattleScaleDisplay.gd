extends Control
class_name TuggaBattleScaleDisplay

@export var score_state: MatchScoreState

@export var player_pips: Array[Control] = []
@export var opponent_pips: Array[Control] = []

@export_range(0.0, 1.0) var inactive_alpha: float = 0.25
@export_range(0.0, 1.0) var active_alpha: float = 1.0

var prepared_pips: Array[Control] = []


func _ready() -> void:
	_prepare_all_pips()
	_connect_score_state()
	_refresh()


func setup(source_score_state: MatchScoreState) -> void:
	score_state = source_score_state
	_prepare_all_pips()
	_connect_score_state()
	_refresh()


func _connect_score_state() -> void:
	if score_state == null:
		return

	if not score_state.score_changed.is_connected(_on_score_changed):
		score_state.score_changed.connect(_on_score_changed)


func _on_score_changed(_score: int) -> void:
	_refresh()


func _refresh() -> void:
	if score_state == null:
		_set_pips(player_pips, 0)
		_set_pips(opponent_pips, 0)
		return

	var score := score_state.score

	_set_pips(player_pips, max(score, 0))
	_set_pips(opponent_pips, max(-score, 0))


func _set_pips(pips: Array[Control], active_count: int) -> void:
	for i in range(pips.size()):
		var pip := pips[i]

		if pip == null:
			continue

		var alpha := inactive_alpha

		if i < active_count:
			alpha = active_alpha

		_set_pip_alpha(pip, alpha)


func _prepare_all_pips() -> void:
	for pip in player_pips:
		_prepare_pip(pip)

	for pip in opponent_pips:
		_prepare_pip(pip)


func _prepare_pip(pip: Control) -> void:
	if pip == null:
		return

	if prepared_pips.has(pip):
		return

	var stylebox := pip.get_theme_stylebox("panel")

	if stylebox == null:
		return

	var flat_stylebox := stylebox as StyleBoxFlat

	if flat_stylebox == null:
		return

	var unique_stylebox := flat_stylebox.duplicate() as StyleBoxFlat
	pip.add_theme_stylebox_override("panel", unique_stylebox)

	prepared_pips.append(pip)


func _set_pip_alpha(pip: Control, alpha: float) -> void:
	if pip == null:
		return

	var stylebox := pip.get_theme_stylebox("panel")
	var flat_stylebox := stylebox as StyleBoxFlat

	if flat_stylebox == null:
		return

	var color := flat_stylebox.bg_color
	color.a = alpha
	flat_stylebox.bg_color = color
