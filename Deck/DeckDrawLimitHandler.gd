extends Node
class_name DeckDrawLimitHandler

static var shared_draws_used_this_turn: int = 0
static var shared_draw_limit_this_turn: int = 2
static var shared_was_in_draw_phase := false

@export var normal_draw_limit: int = 2
@export var empty_hand_draw_limit: int = 3

var phase_manager: PhaseManager = null
var player_hand: Node2D = null


func process_limit_reset() -> void:
	if phase_manager == null:
		return

	if phase_manager.is_draw_phase() and not DeckDrawLimitHandler.shared_was_in_draw_phase:
		DeckDrawLimitHandler.shared_was_in_draw_phase = true
		DeckDrawLimitHandler.shared_draws_used_this_turn = 0
		DeckDrawLimitHandler.shared_draw_limit_this_turn = _get_draw_limit_for_current_hand()

		print("shared draw limit this turn: ", DeckDrawLimitHandler.shared_draw_limit_this_turn)

	elif not phase_manager.is_draw_phase():
		DeckDrawLimitHandler.shared_was_in_draw_phase = false


func can_draw() -> bool:
	process_limit_reset()

	if DeckDrawLimitHandler.shared_draws_used_this_turn >= DeckDrawLimitHandler.shared_draw_limit_this_turn:
		print("draw blocked: max draws this turn")
		return false

	return true


func use_draw() -> void:
	DeckDrawLimitHandler.shared_draws_used_this_turn += 1

	print(
		"draw used: ",
		DeckDrawLimitHandler.shared_draws_used_this_turn,
		"/",
		DeckDrawLimitHandler.shared_draw_limit_this_turn
	)


func _get_draw_limit_for_current_hand() -> int:
	if player_hand != null and player_hand.has_method("get_hand_size"):
		if int(player_hand.get_hand_size()) == 0:
			return empty_hand_draw_limit

	return normal_draw_limit
