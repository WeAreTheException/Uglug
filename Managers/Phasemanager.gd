extends Node
class_name PhaseManager

enum Phase {
	PLAYER_DRAW,
	PLAYER_PLACE,
	OPPONENT_DRAW,
	OPPONENT_PLACE,
	PLAYER_ATTACK,
	OPPONENT_ATTACK
}

const FIRST_PLAYER_DRAWS_PER_TURN := 3
const NORMAL_PLAYER_DRAWS_PER_TURN := 1
const OPPONENT_DRAWS_PER_TURN := 1

const OPPONENT_DRAW_TO_PLACE_DELAY := 0.8
const OPPONENT_PLACE_TO_ATTACK_DELAY := 0.8
const ATTACK_BETWEEN_CARDS_DELAY := 0.5

@export var deck_root: DeckRoot
@export var opponent_hand: Node2D
@export var opponent_spawn_anchor: Node2D
@export var opponent_controller: OpponentController
@export var slots: Array[Node2D] # each = one slot pair root

var current_phase: Phase = Phase.PLAYER_DRAW
var player_draw_count: int = 0
var is_first_player_draw_phase: bool = true

var player_drew_worker_this_phase: bool = false
var player_drew_warrior_this_phase: bool = false

func _ready() -> void:
	if multiplayer.multiplayer_peer == null:
		print("PhaseManager: no multiplayer peer, idle")
		return

	if multiplayer.is_server():
		start_player_draw_phase()
	else:
		current_phase = Phase.OPPONENT_DRAW
		print("CLIENT WAITING: host draws first")

func is_player_draw_phase() -> bool:
	return current_phase == Phase.PLAYER_DRAW

func is_player_place_phase() -> bool:
	return current_phase == Phase.PLAYER_PLACE

func is_player_attack_phase() -> bool:
	return current_phase == Phase.PLAYER_ATTACK

func is_opponent_attack_phase() -> bool:
	return current_phase == Phase.OPPONENT_ATTACK

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

		if multiplayer.multiplayer_peer != null and multiplayer.is_server():
			rpc("begin_client_draw_phase")

func start_player_place_phase() -> void:
	current_phase = Phase.PLAYER_PLACE
	print("PLAYER PLACE PHASE")

@rpc("authority", "call_remote", "reliable")
func begin_client_draw_phase() -> void:
	print("CLIENT DRAW UNLOCKED")
	start_player_draw_phase()

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

	await get_tree().create_timer(OPPONENT_DRAW_TO_PLACE_DELAY).timeout
	start_opponent_place_phase()

func start_opponent_place_phase() -> void:
	current_phase = Phase.OPPONENT_PLACE
	print("OPPONENT PLACE PHASE")

	if opponent_controller == null:
		print("Opponent place failed: missing opponent_controller")
		return

	opponent_controller.place_cards()

	await get_tree().create_timer(OPPONENT_PLACE_TO_ATTACK_DELAY).timeout
	start_player_attack_phase()

func start_player_attack_phase() -> void:
	current_phase = Phase.PLAYER_ATTACK
	print("PLAYER ATTACK PHASE")

	var player_cards: Array = get_all_slotted_cards_for_owner(Card.Owner.PLAYER)

	for card in player_cards:
		trigger_card_attack(card)
		await get_tree().create_timer(ATTACK_BETWEEN_CARDS_DELAY).timeout

	start_opponent_attack_phase()

func start_opponent_attack_phase() -> void:
	current_phase = Phase.OPPONENT_ATTACK
	print("OPPONENT ATTACK PHASE")

	var opponent_cards: Array = get_all_slotted_cards_for_owner(Card.Owner.OPPONENT)

	for card in opponent_cards:
		trigger_card_attack(card)
		await get_tree().create_timer(ATTACK_BETWEEN_CARDS_DELAY).timeout

	start_player_draw_phase()

func get_all_slotted_cards_for_owner(owner: int) -> Array:
	var cards: Array = []

	for pair_root in slots:
		if pair_root == null:
			continue

		for child in pair_root.get_children():
			if child is NewSlots:
				var slot: NewSlots = child

				if slot.current_card == null:
					continue

				if slot.current_card.card_owner == owner:
					cards.append(slot.current_card)

	return cards

func trigger_card_attack(card) -> void:
	if card == null:
		return

	var state_machine = card.get_node_or_null("CardStateMachine")
	if state_machine == null:
		print("Attack skipped: no CardStateMachine on ", card.name)
		return

	state_machine.set_main_state(CardStateMachine.MainState.ATTACK)
