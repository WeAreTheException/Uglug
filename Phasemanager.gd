extends Node
class_name PhaseManager

enum Phase {
	PLAYER_DRAW,
	PLAYER_PLACE,
	OPPONENT_DRAW
}

const PLAYER_DRAWS_PER_TURN := 2

var current_phase: Phase = Phase.PLAYER_DRAW
var player_draw_count: int = 0

func _ready() -> void:
	start_player_draw_phase()

func is_player_draw_phase() -> bool:
	return current_phase == Phase.PLAYER_DRAW

func is_player_place_phase() -> bool:
	return current_phase == Phase.PLAYER_PLACE

func is_opponent_draw_phase() -> bool:
	return current_phase == Phase.OPPONENT_DRAW

func start_player_draw_phase() -> void:
	current_phase = Phase.PLAYER_DRAW
	player_draw_count = 0
	print("PLAYER DRAW PHASE")

func on_player_drew_card() -> void:
	if not is_player_draw_phase():
		return

	player_draw_count += 1
	print("PLAYER DRAWS: ", player_draw_count)

	if player_draw_count >= PLAYER_DRAWS_PER_TURN:
		start_player_place_phase()

func start_player_place_phase() -> void:
	current_phase = Phase.PLAYER_PLACE
	print("PLAYER PLACE PHASE")

func end_player_place_phase() -> void:
	if not is_player_place_phase():
		return

	start_opponent_draw_phase()

func start_opponent_draw_phase() -> void:
	current_phase = Phase.OPPONENT_DRAW
	print("OPPONENT DRAW PHASE")
