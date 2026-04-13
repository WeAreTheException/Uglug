extends Node
class_name PhaseManager

enum Phase {
	PLAYER_DRAW,
	PLAYER_PLACE,
	OPPONENT_DRAW,
	OPPONENT_PLACE
}

const PLAYER_DRAWS_PER_TURN := 2
const OPPONENT_DRAWS_PER_TURN := 2

@export var deck_root: DeckRoot
@export var opponent_hand: Node2D
@export var opponent_spawn_anchor: Node2D
@export var opponent_controller: OpponentController

var current_phase: Phase = Phase.PLAYER_DRAW
var player_draw_count: int = 0

func _ready() -> void:
	start_player_draw_phase()

func is_player_draw_phase() -> bool:
	return current_phase == Phase.PLAYER_DRAW

func is_player_place_phase() -> bool:
	return current_phase == Phase.PLAYER_PLACE

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

	if deck_root == null or deck_root.draw_handler == null:
		print("Opponent draw failed: missing deck")
		return

	for i in OPPONENT_DRAWS_PER_TURN:
		deck_root.draw_handler.draw_card_to_hand(
			opponent_hand,
			opponent_spawn_anchor,
			Card.Owner.OPPONENT
		)

	start_opponent_place_phase()

func start_opponent_place_phase() -> void:
	current_phase = Phase.OPPONENT_PLACE
	print("OPPONENT PLACE PHASE")

	if opponent_controller != null:
		opponent_controller.place_cards()

	start_player_draw_phase()
