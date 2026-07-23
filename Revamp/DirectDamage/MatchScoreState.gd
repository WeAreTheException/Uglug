extends Node
class_name MatchScoreState

signal score_changed(score: int)
signal threshold_reached(winner: SlotRow.SlotOwner, score: int)

@export var win_threshold: int = 10
@export var print_debug: bool = true

var score: int = 0

var win_check_pending: bool = false
var has_winner: bool = false
var winner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER


func reset_score() -> void:
	score = 0
	win_check_pending = false
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
	if win_check_pending:
		return

	if score >= win_threshold:
		_queue_win_check()
		return

	if score <= -win_threshold:
		_queue_win_check()


func _queue_win_check() -> void:
	win_check_pending = true

	if print_debug:
		print(
			"WIN CHECK QUEUED | score=",
			score,
			" threshold=",
			win_threshold
		)


func finalize_pending_win_check() -> bool:
	if has_winner:
		return false

	if not win_check_pending:
		return false

	win_check_pending = false

	if score >= win_threshold:
		_set_winner(SlotRow.SlotOwner.PLAYER)
		return true

	if score <= -win_threshold:
		_set_winner(SlotRow.SlotOwner.OPPONENT)
		return true

	if print_debug:
		print(
			"WIN CHECK CLEARED | final score returned below threshold: ",
			score
		)

	return false


func _set_winner(source_winner: SlotRow.SlotOwner) -> void:
	if has_winner:
		return

	has_winner = true
	winner = source_winner

	if print_debug:
		print(
			"WINNER FINALIZED: ",
			_get_owner_name(winner),
			" score=",
			score
		)

	threshold_reached.emit(winner, score)


func apply_confirmed_score_change(
	previous_score: int,
	new_score: int,
	attacker_owner: SlotRow.SlotOwner,
	amount: int,
	event_id: int,
	is_local_host: bool
) -> void:
	score = new_score
	score_changed.emit(score)

	_check_threshold()

	if print_debug:
		var role := "CLIENT"

		if is_local_host:
			role = "HOST"

		print(
			"SCORE CONFIRMED | role=",
			role,
			" event_id=",
			event_id,
			" previous=",
			previous_score,
			" new=",
			new_score,
			" attacker=",
			_get_owner_name(attacker_owner),
			" amount=",
			amount
		)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
