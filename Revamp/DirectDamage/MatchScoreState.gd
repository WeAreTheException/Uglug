extends Node
class_name MatchScoreState

signal score_changed(score: int)
signal threshold_reached(winner: SlotRow.SlotOwner, score: int)

@export var win_threshold: int = 5
@export var print_debug: bool = true

var score: int = 0
var has_winner: bool = false
var winner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER


func reset_score() -> void:
	score = 0
	has_winner = false
	winner = SlotRow.SlotOwner.PLAYER
	score_changed.emit(score)


func apply_direct_damage(
	attacker_owner: SlotRow.SlotOwner,
	amount: int
) -> void:
	if has_winner:
		return

	if amount <= 0:
		return

	if attacker_owner == SlotRow.SlotOwner.PLAYER:
		score += amount
	else:
		score -= amount

	score_changed.emit(score)

	if print_debug:
		print("MATCH SCORE: ", score)

	_check_threshold()


func _check_threshold() -> void:
	if score >= win_threshold:
		_set_winner(SlotRow.SlotOwner.PLAYER)
		return

	if score <= -win_threshold:
		_set_winner(SlotRow.SlotOwner.OPPONENT)


func _set_winner(source_winner: SlotRow.SlotOwner) -> void:
	if has_winner:
		return

	has_winner = true
	winner = source_winner

	if print_debug:
		print("WINNER REACHED: ", _get_owner_name(winner))

	threshold_reached.emit(winner, score)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
