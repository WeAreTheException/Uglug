extends Node
class_name PhaseManager

enum Phase {
	PLAYER_DRAW,
	PLAYER_PLACE,
	OPPONENT_DRAW
}

const PLAYER_DRAWS_PER_TURN := 2
const OPPONENT_DRAWS_PER_TURN := 2

@export var deck_root: DeckRoot
@export var opponent_hand: Node2D
@export var opponent_spawn_anchor: Node2D

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

	if deck_root == null:
		print("OPPONENT DRAW FAILED: deck_root is null")
		return

	if deck_root.draw_handler == null:
		print("OPPONENT DRAW FAILED: draw_handler is null")
		return

	if opponent_hand == null:
		print("OPPONENT DRAW FAILED: opponent_hand is null")
		return

	if opponent_spawn_anchor == null:
		print("OPPONENT DRAW FAILED: opponent_spawn_anchor is null")
		return

	for i in OPPONENT_DRAWS_PER_TURN:
		deck_root.draw_handler.draw_card_to_hand(
			opponent_hand,
			opponent_spawn_anchor,
			Card.Owner.OPPONENT
		)

	start_player_draw_phase()
