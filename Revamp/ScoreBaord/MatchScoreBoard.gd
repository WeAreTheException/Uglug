extends Node2D
class_name MatchScoreBoard

@export_group("Labels")
@export var your_score_label: Label
@export var enemy_score_label: Label

@export_group("Match References")
@export var score_state: MatchScoreState
@export var match_network_root: MatchNetworkRoot

@export_group("Score Display")
@export var starting_score: int = 5

@export_group("Offline Testing")
@export var offline_local_owner: SlotRow.SlotOwner = (
	SlotRow.SlotOwner.PLAYER
)


func _ready() -> void:
	if score_state == null:
		return

	if not score_state.score_changed.is_connected(_on_score_changed):
		score_state.score_changed.connect(_on_score_changed)

	_refresh_score(score_state.score)


func _on_score_changed(new_score: int) -> void:
	_refresh_score(new_score)


func _refresh_score(score_difference: int) -> void:
	var player_score: int = max(
		starting_score + score_difference,
		0
	)

	var opponent_score: int = max(
		starting_score - score_difference,
		0
	)

	var your_score: int = player_score
	var enemy_score: int = opponent_score

	if _get_local_owner() == SlotRow.SlotOwner.OPPONENT:
		your_score = opponent_score
		enemy_score = player_score

	if your_score_label != null:
		your_score_label.text = str(your_score)

	if enemy_score_label != null:
		enemy_score_label.text = str(enemy_score)


func _get_local_owner() -> SlotRow.SlotOwner:
	if match_network_root == null:
		return offline_local_owner

	if match_network_root.is_host():
		return SlotRow.SlotOwner.PLAYER

	return SlotRow.SlotOwner.OPPONENT
