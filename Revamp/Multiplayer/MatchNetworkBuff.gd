extends Node
class_name MatchNetworkBuff

signal confirmed_buff_applied(
	owner: SlotRow.SlotOwner,
	card: CardRoot,
	mutation: Mutation
)

@export var phase_timer: MatchPhaseTimer
@export var selection_state: BuffSelectionState

var root: MatchNetworkRoot = null
var confirmed_owners: Dictionary = {}
var is_phase_finishing: bool = false


func setup(
	source_root: MatchNetworkRoot
) -> void:
	root = source_root

	_connect_timer()
	_connect_match_flow()


func on_buff_phase_started() -> void:
	if root == null:
		return

	if not root.is_host():
		return

	confirmed_owners.clear()
	is_phase_finishing = false

	if root.buff_database == null:
		print(
			"HOST BUFF ROLL BLOCKED: "
			+ "buff_database missing"
		)
		return

	var mutation: Mutation = (
		root.buff_database.draw_random_mutation()
	)

	if mutation == null:
		print(
			"HOST BUFF ROLL BLOCKED: no mutation"
		)
		return

	var mutation_id: String = (
		mutation.get_safe_mutation_id()
	)

	if root.print_debug:
		print(
			"HOST BUFF ROLLED: ",
			mutation_id
		)

	GDSync.call_func_all(
		root._receive_buff_reward,
		mutation_id
	)


func receive_buff_reward(
	mutation_id: String
) -> void:
	if root == null:
		return

	if root.buff_database == null:
		print(
			"BUFF RECEIVE FAILED: "
			+ "buff_database missing"
		)
		return

	if root.buff_flow_handler == null:
		print(
			"BUFF RECEIVE FAILED: "
			+ "buff_flow_handler missing"
		)
		return

	var mutation: Mutation = (
		root.buff_database.get_mutation_by_id(
			mutation_id
		)
	)

	if mutation == null:
		print(
			"BUFF RECEIVE FAILED: ",
			mutation_id
		)
		return

	if root.print_debug:
		print(
			"BUFF RECEIVE: ",
			mutation.mutation_name,
			" | HOST: ",
			root.is_host()
		)

	root.buff_flow_handler.begin_buff_flow_with_reward(
		mutation
	)


func request_buff_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if root == null:
		return

	if root.is_host():
		_process_buff_confirm_request(
			owner,
			target_card_runtime_id,
			mutation_id
		)
		return

	GDSync.call_func(
		root.request_buff_confirm,
		owner,
		target_card_runtime_id,
		mutation_id
	)


func receive_confirmed_buff(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if root == null:
		return

	if root.buff_database == null:
		print(
			"CONFIRMED BUFF FAILED: "
			+ "buff_database missing"
		)
		return

	var card: CardRoot = root.find_card_anywhere(
		target_card_runtime_id
	)

	if card == null:
		print(
			"CONFIRMED BUFF FAILED: card missing ",
			target_card_runtime_id
		)
		return

	var mutation: Mutation = (
		root.buff_database.get_mutation_by_id(
			mutation_id
		)
	)

	if mutation == null:
		print(
			"CONFIRMED BUFF FAILED: mutation missing ",
			mutation_id
		)
		return

	if not card.can_receive_buff_mutation(
		mutation
	):
		print(
			"CONFIRMED BUFF FAILED: "
			+ "card cannot receive mutation"
		)
		return

	var applied: bool = card.add_buff_mutation(
		mutation
	)

	if not applied:
		print(
			"CONFIRMED BUFF FAILED: add failed"
		)
		return

	_play_local_evolution_feedback(
		owner,
		card
	)

	confirmed_buff_applied.emit(
		owner,
		card,
		mutation
	)

	if root.print_debug:
		print(
			"CONFIRMED BUFF APPLIED: ",
			root.get_owner_name(owner),
			" ",
			mutation.mutation_name,
			" -> ",
			card.card_name
		)


func _play_local_evolution_feedback(
	owner: SlotRow.SlotOwner,
	card: CardRoot
) -> void:
	if root == null:
		return

	# Each player plays feedback only for their own
	# confirmed Evolution.
	if owner != root.get_local_owner():
		return

	if root.deck_system_root == null:
		print(
			"EVOLUTION FEEDBACK BLOCKED: "
			+ "DeckSystemRoot missing"
		)
		return

	var local_hand: PlayerHandRoot = (
		root.deck_system_root.get_hand_for_owner(
			root.get_local_owner()
		)
	)

	# Fall back to whichever hand actually contains
	# this local card.
	if (
		local_hand == null
		or not local_hand.has_card(card)
	):
		local_hand = (
			root.deck_system_root
			.get_hand_for_card_owner(card)
		)

	if local_hand == null:
		print(
			"EVOLUTION FEEDBACK BLOCKED: "
			+ "card hand missing"
		)
		return

	if not local_hand.has_card(card):
		print(
			"EVOLUTION FEEDBACK BLOCKED: "
			+ "card not found in local hand"
		)
		return

	# The buff phase may finish during this same
	# network call. Defer feedback until the layout
	# has finished responding to that phase change.
	local_hand.call_deferred(
		"play_evolution_feedback",
		card
	)

	if root.print_debug:
		print(
			"EVOLUTION FEEDBACK QUEUED: ",
			card.card_name,
			" | LOCAL OWNER: ",
			root.get_owner_name(
				root.get_local_owner()
			)
		)


func receive_buff_flow_finished() -> void:
	if phase_timer != null:
		phase_timer.stop_timer()

	if root == null:
		return

	if root.buff_flow_handler != null:
		root.buff_flow_handler.finish_buff_flow()


func _connect_timer() -> void:
	if phase_timer == null:
		return

	if not phase_timer.timer_finished.is_connected(
		_on_timer_finished
	):
		phase_timer.timer_finished.connect(
			_on_timer_finished
		)


func _connect_match_flow() -> void:
	if root == null:
		return

	if root.match_flow_root == null:
		return

	if not root.match_flow_root.match_state_changed.is_connected(
		_on_match_state_changed
	):
		root.match_flow_root.match_state_changed.connect(
			_on_match_state_changed
		)


func _on_match_state_changed(
	state: MatchFlowRoot.MatchState
) -> void:
	if state == MatchFlowRoot.MatchState.BUFF:
		confirmed_owners.clear()
		is_phase_finishing = false


func _process_buff_confirm_request(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if is_phase_finishing:
		print(
			"BUFF REQUEST REJECTED: "
			+ "phase already finishing"
		)
		return

	if confirmed_owners.has(owner):
		print(
			"BUFF REQUEST REJECTED: "
			+ "owner already confirmed"
		)
		return

	if root.buff_database == null:
		print(
			"BUFF REQUEST REJECTED: "
			+ "buff_database missing"
		)
		return

	var card: CardRoot = root.find_card_anywhere(
		target_card_runtime_id
	)

	if card == null:
		print(
			"BUFF REQUEST REJECTED: card missing ",
			target_card_runtime_id
		)
		return

	if root.lookup_network == null:
		print(
			"BUFF REQUEST REJECTED: "
			+ "lookup_network missing"
		)
		return

	if not root.lookup_network.card_belongs_to_owner_hand(
		card,
		owner
	):
		print(
			"BUFF REQUEST REJECTED: wrong owner"
		)
		return

	var mutation: Mutation = (
		root.buff_database.get_mutation_by_id(
			mutation_id
		)
	)

	if mutation == null:
		print(
			"BUFF REQUEST REJECTED: mutation missing ",
			mutation_id
		)
		return

	if root.buff_flow_handler != null:
		var offered: Mutation = (
			root.buff_flow_handler
			.get_active_reward_mutation()
		)

		if (
			offered != null
			and offered.get_safe_mutation_id()
			!= mutation_id
		):
			print(
				"BUFF REQUEST REJECTED: "
				+ "mutation was not offered"
			)
			return

	if not card.can_receive_buff_mutation(
		mutation
	):
		print(
			"BUFF REQUEST REJECTED: "
			+ "card cannot receive mutation"
		)
		return

	confirmed_owners[owner] = true

	_broadcast_confirmed_buff(
		owner,
		target_card_runtime_id,
		mutation_id
	)

	_try_finish_if_all_confirmed()


func _broadcast_confirmed_buff(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if root.print_debug:
		print(
			"BUFF CONFIRMED: ",
			root.get_owner_name(owner),
			" ",
			target_card_runtime_id,
			" ",
			mutation_id
		)

	GDSync.call_func_all(
		root._receive_confirmed_buff,
		owner,
		target_card_runtime_id,
		mutation_id
	)


func _try_finish_if_all_confirmed() -> void:
	var player_confirmed: bool = (
		confirmed_owners.has(
			SlotRow.SlotOwner.PLAYER
		)
	)

	var opponent_confirmed: bool = (
		confirmed_owners.has(
			SlotRow.SlotOwner.OPPONENT
		)
	)

	if player_confirmed and opponent_confirmed:
		_finish_buff_phase()


func _on_timer_finished(
	state: MatchFlowRoot.MatchState
) -> void:
	if root == null:
		return

	if not root.is_host():
		return

	if is_phase_finishing:
		return

	if state != MatchFlowRoot.MatchState.BUFF:
		return

	_resolve_unconfirmed_owner(
		SlotRow.SlotOwner.PLAYER
	)

	_resolve_unconfirmed_owner(
		SlotRow.SlotOwner.OPPONENT
	)

	_finish_buff_phase()


func _resolve_unconfirmed_owner(
	owner: SlotRow.SlotOwner
) -> void:
	if is_phase_finishing:
		return

	if confirmed_owners.has(owner):
		return

	if root.buff_flow_handler == null:
		return

	var mutation: Mutation = (
		root.buff_flow_handler
		.get_active_reward_mutation()
	)

	if mutation == null:
		return

	var card: CardRoot = _get_fallback_card(
		owner,
		mutation
	)

	if card == null:
		print(
			"BUFF TIMEOUT FAILED: "
			+ "no fallback card for ",
			root.get_owner_name(owner)
		)
		return

	confirmed_owners[owner] = true

	_broadcast_confirmed_buff(
		owner,
		card.get_runtime_id(),
		mutation.get_safe_mutation_id()
	)


func _get_fallback_card(
	owner: SlotRow.SlotOwner,
	mutation: Mutation
) -> CardRoot:
	if selection_state != null:
		var selected: CardRoot = (
			selection_state.get_selected_card(
				owner
			)
		)

		if (
			selected != null
			and selected.can_receive_buff_mutation(
				mutation
			)
		):
			return selected

	if root == null:
		return null

	if root.deck_system_root == null:
		return null

	var hand: PlayerHandRoot = (
		root.deck_system_root.get_hand_for_owner(
			owner
		)
	)

	if hand == null:
		return null

	var valid_cards: Array[CardRoot] = []

	for card: CardRoot in hand.get_cards():
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if not card.can_receive_buff_mutation(
			mutation
		):
			continue

		valid_cards.append(card)

	if valid_cards.is_empty():
		return null

	return valid_cards.pick_random()


func _finish_buff_phase() -> void:
	if root == null:
		return

	if is_phase_finishing:
		return

	is_phase_finishing = true

	GDSync.call_func_all(
		root._receive_buff_flow_finished
	)
