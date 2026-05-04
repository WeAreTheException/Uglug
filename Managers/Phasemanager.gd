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

const FIRST_PLAYER_DRAWS_PER_TURN := 4
const NORMAL_PLAYER_DRAWS_PER_TURN := 3
const OPPONENT_DRAWS_PER_TURN := 1

const OPPONENT_DRAW_TO_PLACE_DELAY := 0.8
const OPPONENT_PLACE_TO_ATTACK_DELAY := 0.8
const ATTACK_BETWEEN_CARDS_DELAY := 0.5

const DEBUG_PLACE_SECONDS := 6.0

@export var deck_root: DeckRoot
@export var opponent_hand: Node2D
@export var opponent_spawn_anchor: Node2D
@export var opponent_controller: OpponentController
@export var slots: Array[Node2D]

var current_phase: Phase = Phase.PLAYER_DRAW
var player_draw_count: int = 0
var is_first_player_draw_phase: bool = true

var player_drew_worker_this_phase: bool = false
var player_drew_warrior_this_phase: bool = false

var first_placer_id: int = -1
var second_placer_id: int = -1
var place_window_active: bool = false

func _ready() -> void:
	if not GDSync.is_active():
		print("PhaseManager: GD-Sync not active, idle")
		return

	GDSync.expose_node(self)
	GDSync.expose_func(begin_client_draw_phase)
	GDSync.expose_func(notify_client_draw_done)
	GDSync.expose_func(apply_place_order)
	GDSync.expose_func(notify_first_place_done)
	GDSync.expose_func(apply_second_place)
	GDSync.expose_func(notify_second_place_done)

	if GDSync.is_host():
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

	if player_draw_count < get_player_draw_limit():
		return

	if is_first_player_draw_phase:
		is_first_player_draw_phase = false

	if GDSync.is_host():
		current_phase = Phase.OPPONENT_DRAW
		print("HOST DONE DRAWING. WAITING FOR CLIENT DRAW.")
		unlock_client_draw_phase()
	else:
		current_phase = Phase.OPPONENT_PLACE
		print("CLIENT DONE DRAWING. TELLING HOST.")
		GDSync.call_func_on(GDSync.get_host(), notify_client_draw_done)

func unlock_client_draw_phase() -> void:
	var clients := GDSync.lobby_get_all_clients()
	var my_id := GDSync.get_client_id()

	for client_id in clients:
		if client_id == my_id:
			continue

		print("unlocking client draw for client id: ", client_id)
		GDSync.call_func_on(client_id, begin_client_draw_phase)
		return

	print("unlock_client_draw_phase: no other client found")

func begin_client_draw_phase() -> void:
	print("CLIENT DRAW UNLOCKED")
	start_player_draw_phase()

func notify_client_draw_done() -> void:
	if not GDSync.is_host():
		return

	print("HOST RECEIVED: client done drawing")
	choose_random_place_order()

func choose_random_place_order() -> void:
	var clients := GDSync.lobby_get_all_clients()

	if clients.size() < 2:
		print("choose_random_place_order failed: not enough clients")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var index := rng.randi_range(0, clients.size() - 1)
	first_placer_id = int(clients[index])

	for id in clients:
		if int(id) != first_placer_id:
			second_placer_id = int(id)
			break

	print("RANDOM PLACE ORDER CHOSEN")
	print("FIRST PLACER ID: ", first_placer_id)
	print("SECOND PLACER ID: ", second_placer_id)

	GDSync.call_func_all(apply_place_order, first_placer_id, second_placer_id)

func apply_place_order(first_id: int, second_id: int) -> void:
	first_placer_id = first_id
	second_placer_id = second_id

	var my_id := GDSync.get_client_id()

	print("PLACE ORDER RECEIVED")
	print("my id: ", my_id)
	print("first placer: ", first_placer_id)
	print("second placer: ", second_placer_id)

	if my_id == first_placer_id:
		print("I PLACE FIRST")
		start_player_place_phase()
	else:
		current_phase = Phase.OPPONENT_PLACE
		print("I WAIT. OPPONENT PLACES FIRST.")

func start_player_place_phase() -> void:
	current_phase = Phase.PLAYER_PLACE
	place_window_active = true
	print("PLAYER PLACE PHASE")
	print("DEBUG: you have ", DEBUG_PLACE_SECONDS, " seconds to place cards")

	_auto_end_place_phase_after_delay()

func _auto_end_place_phase_after_delay() -> void:
	await get_tree().create_timer(DEBUG_PLACE_SECONDS).timeout

	if not place_window_active:
		return

	if not is_player_place_phase():
		return

	end_player_place_phase()

func end_player_place_phase() -> void:
	if not is_player_place_phase():
		return

	place_window_active = false
	print("PLAYER PLACE PHASE ENDED")

	var my_id := GDSync.get_client_id()

	if my_id == first_placer_id:
		print("FIRST PLACER DONE")
		if GDSync.is_host():
			notify_first_place_done()
		else:
			GDSync.call_func_on(GDSync.get_host(), notify_first_place_done)
	elif my_id == second_placer_id:
		print("SECOND PLACER DONE")
		if GDSync.is_host():
			notify_second_place_done()
		else:
			GDSync.call_func_on(GDSync.get_host(), notify_second_place_done)

func notify_first_place_done() -> void:
	if not GDSync.is_host():
		return

	print("HOST RECEIVED: first placer done")
	print("UNLOCKING SECOND PLACER: ", second_placer_id)

	GDSync.call_func_all(apply_second_place, second_placer_id)

func apply_second_place(second_id: int) -> void:
	second_placer_id = second_id

	var my_id := GDSync.get_client_id()

	if my_id == second_placer_id:
		print("I PLACE SECOND NOW")
		start_player_place_phase()
	else:
		current_phase = Phase.OPPONENT_PLACE
		print("I AM DONE. OPPONENT PLACES SECOND.")

func notify_second_place_done() -> void:
	if not GDSync.is_host():
		return

	print("HOST RECEIVED: second placer done")
	print("DEBUG PLACEMENT ORDER TEST COMPLETE")

func begin_client_place_phase() -> void:
	print("CLIENT PLACE UNLOCKED")
	start_player_place_phase()

func notify_client_place_done() -> void:
	pass

func run_attack_round_remote(host_peer: int, second_peer: int) -> void:
	pass

func run_single_attack_phase_for_peer(attacker_peer_id: int) -> void:
	pass

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
