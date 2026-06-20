extends Node
class_name MatchNetworkScore

var root: MatchNetworkRoot = null
var event_id: int = 0


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func request_score_damage(
	attacker_owner: SlotRow.SlotOwner,
	amount: int
) -> void:
	if root == null:
		return

	if amount <= 0:
		return

	if root.is_host():
		_host_apply_score_damage(attacker_owner, amount)
		return

	GDSync.call_func_on(
		1,
		root.request_score_damage,
		attacker_owner,
		amount
	)


func _host_apply_score_damage(
	attacker_owner: SlotRow.SlotOwner,
	amount: int
) -> void:
	if root == null:
		return

	if not root.is_host():
		return

	if root.match_score_state == null:
		return

	var previous_score := root.match_score_state.score

	root.match_score_state.apply_direct_damage(
		attacker_owner,
		amount
	)

	var new_score := root.match_score_state.score

	if previous_score == new_score:
		return

	event_id += 1

	var payload := {
		"event_id": event_id,
		"previous_score": previous_score,
		"new_score": new_score,
		"attacker_owner": int(attacker_owner),
		"amount": amount
	}

	GDSync.call_func_all(root._receive_confirmed_score_change, payload)
	
	if root.match_score_state.has_winner:
		_broadcast_confirmed_match_winner()

func _broadcast_confirmed_match_winner() -> void:
	if root == null:
		return

	if root.match_score_state == null:
		return

	event_id += 1

	var payload := {
		"event_id": event_id,
		"winner": int(root.match_score_state.winner),
		"final_score": root.match_score_state.score
	}

	GDSync.call_func_all(root._receive_confirmed_match_winner, payload)
