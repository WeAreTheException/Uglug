extends Node
class_name PhaseManager

enum Phase {
	PLAYER_DRAW,
	PLAYER_PLACE,
	OPPONENT_DRAW,
	OPPONENT_PLACE
}

const FIRST_PLAYER_DRAWS_PER_TURN := 4
const NORMAL_PLAYER_DRAWS_PER_TURN := 3
const OPPONENT_DRAWS_PER_TURN := 2

@export var deck_root: DeckRoot
@export var opponent_hand: Node2D
@export var opponent_spawn_anchor: Node2D
@export var opponent_controller: OpponentController

var current_phase: Phase = Phase.PLAYER_DRAW
var player_draw_count: int = 0
var is_first_player_draw_phase: bool = true

var player_drew_worker_this_phase: bool = false
var player_drew_warrior_this_phase: bool = false

func _ready() -> void:
	start_player_draw_phase()

func is_player_draw_phase() -> bool:
	return current_phase == Phase.PLAYER_DRAW

func is_player_place_phase() -> bool:
	return current_phase == Phase.PLAYER_PLACE

func get_player_draw_limit() -> int:
	if is_first_player_draw_phase:
		return FIRST_PLAYER_DRAWS_PER_TURN
	return NORMAL_PLAYER_DRAWS_PER_TURN

func start_player_draw_phase() -> void:
	current_phase = Phase.PLAYER_DRAW
	player_draw_count = 0
	player_drew_worker_this_phase = false
	player_drew_warrior_this_phase = false
	print("PLAYER DRAW PHASE")

func can_draw_worker_card() -> bool:
	if not is_player_draw_phase():
		return false
	if player_drew_warrior_this_phase:
		return false
	return player_draw_count < get_player_draw_limit()

func can_draw_warrior_card() -> bool:
	if not is_player_draw_phase():
		return false
	if not player_drew_worker_this_phase:
		return false
	return player_draw_count < get_player_draw_limit()

func on_player_drew_worker_card() -> void:
	if not can_draw_worker_card():
		print("Worker draw blocked")
		return

	player_drew_worker_this_phase = true
	on_player_drew_card()

func on_player_drew_warrior_card() -> void:
	if not can_draw_warrior_card():
		print("Warrior draw blocked")
		return

	player_drew_warrior_this_phase = true
	on_player_drew_card()

func on_player_drew_card() -> void:
	if not is_player_draw_phase():
		return

	player_draw_count += 1
	print("PLAYER DRAWS: ", player_draw_count)

	if player_draw_count >= get_player_draw_limit():
		if is_first_player_draw_phase:
			is_first_player_draw_phase = false
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

	for i in range(OPPONENT_DRAWS_PER_TURN):
		deck_root.draw_handler.draw_card_to_hand(
			opponent_hand,
			opponent_spawn_anchor,
			Card.Owner.OPPONENT
		)

	await get_tree().create_timer(0.8).timeout
	start_opponent_place_phase()

func start_opponent_place_phase() -> void:
	current_phase = Phase.OPPONENT_PLACE
	print("OPPONENT PLACE PHASE")

	if opponent_controller == null:
		print("Opponent place failed: missing opponent_controller")
		return

	opponent_controller.place_cards()

	await get_tree().create_timer(0.8).timeout
	start_player_draw_phase()
