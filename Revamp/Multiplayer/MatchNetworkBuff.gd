extends Node
class_name MatchNetworkBuff

@export var phase_timer: MatchPhaseTimer
@export var selection_state: BuffSelectionState

var root: MatchNetworkRoot = null
var confirmed_owners: Dictionary = {}


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root
	_connect_timer()


func on_buff_phase_started() -> void:
	if root == null:
		return

	if not root.is_host():
		return

	confirmed_owners.clear()

	if root.buff_database == null:
		print("HOST BUFF ROLL BLOCKED: buff_database missing")
		return

	var mutation := root.buff_database.draw_random_mutation()

	if mutation == null:
		print("HOST BUFF ROLL BLOCKED: no mutation")
		return

	var mutation_id := mutation.get_safe_mutation_id()

	if root.print_debug:
		print("HOST BUFF ROLLED: ", mutation_id)

	GDSync.call_func_all(root._receive_buff_reward, mutation_id)


func receive_buff_reward(mutation_id: String) -> void:
	if root == null:
		return

	if root.buff_database == null:
		print("BUFF RECEIVE FAILED: buff_database missing")
		return

	if root.buff_flow_handler == null:
		print("BUFF RECEIVE FAILED: buff_flow_handler missing")
		return

	var mutation := root.buff_database.get_mutation_by_id(mutation_id)

	if mutation == null:
		print("BUFF RECEIVE FAILED: ", mutation_id)
		return

	if root.print_debug:
		print("BUFF RECEIVE: ", mutation.mutation_name, " | HOST: ", root.is_host())

	root.buff_flow_handler.begin_buff_flow_with_reward(mutation)


func request_buff_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if root == null:
		return

	if root.is_host():
		_process_buff_confirm_request(owner, target_card_runtime_id, mutation_id)
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
		print("CONFIRMED BUFF FAILED: buff_database missing")
		return

	var card := root.find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("CONFIRMED BUFF FAILED: card missing ", target_card_runtime_id)
		return

	var mutation := root.buff_database.get_mutation_by_id(mutation_id)

	if mutation == null:
		print("CONFIRMED BUFF FAILED: mutation missing ", mutation_id)
		return

	if not card.can_receive_buff_mutation(mutation):
		print("CONFIRMED BUFF FAILED: card cannot receive mutation")
		return

	var applied := card.add_buff_mutation(mutation)

	if not applied:
		print("CONFIRMED BUFF FAILED: add failed")
		return

	if root.print_debug:
		print(
			"CONFIRMED BUFF APPLIED: ",
			root.get_owner_name(owner),
			" ",
			mutation.mutation_name,
			" -> ",
			card.card_name
		)


func _connect_timer() -> void:
	if phase_timer == null:
		return

	if not phase_timer.timer_finished.is_connected(_on_timer_finished):
		phase_timer.timer_finished.connect(_on_timer_finished)


func _process_buff_confirm_request(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if confirmed_owners.has(owner):
		print("BUFF REQUEST REJECTED: owner already confirmed")
		return

	if root.buff_database == null:
		print("BUFF REQUEST REJECTED: buff_database missing")
		return

	var card := root.find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("BUFF REQUEST REJECTED: card missing ", target_card_runtime_id)
		return

	if root.lookup_network == null:
		print("BUFF REQUEST REJECTED: lookup_network missing")
		return

	if not root.lookup_network.card_belongs_to_owner_hand(card, owner):
		print("BUFF REQUEST REJECTED: wrong owner")
		return

	var mutation := root.buff_database.get_mutation_by_id(mutation_id)

	if mutation == null:
		print("BUFF REQUEST REJECTED: mutation missing ", mutation_id)
		return

	if root.buff_flow_handler != null:
		var offered := root.buff_flow_handler.get_active_reward_mutation()

		if offered != null and offered.get_safe_mutation_id() != mutation_id:
			print("BUFF REQUEST REJECTED: mutation was not offered")
			return

	if not card.can_receive_buff_mutation(mutation):
		print("BUFF REQUEST REJECTED: card cannot receive mutation")
		return

	_broadcast_confirmed_buff(owner, target_card_runtime_id, mutation_id)

	confirmed_owners[owner] = true
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
	if confirmed_owners.has(SlotRow.SlotOwner.PLAYER) and confirmed_owners.has(SlotRow.SlotOwner.OPPONENT):
		_finish_buff_phase()


func _on_timer_finished(state: MatchFlowRoot.MatchState) -> void:
	if root == null:
		return

	if not root.is_host():
		return

	if state != MatchFlowRoot.MatchState.BUFF:
		return

	_resolve_unconfirmed_owner(SlotRow.SlotOwner.PLAYER)
	_resolve_unconfirmed_owner(SlotRow.SlotOwner.OPPONENT)
	_finish_buff_phase()


func _resolve_unconfirmed_owner(owner: SlotRow.SlotOwner) -> void:
	if confirmed_owners.has(owner):
		return

	if root.buff_flow_handler == null:
		return

	var mutation := root.buff_flow_handler.get_active_reward_mutation()

	if mutation == null:
		return

	var card := _get_fallback_card(owner, mutation)

	if card == null:
		print("BUFF TIMEOUT FAILED: no fallback card for ", root.get_owner_name(owner))
		return

	confirmed_owners[owner] = true

	_broadcast_confirmed_buff(
		owner,
		card.get_runtime_id(),
		mutation.get_safe_mutation_id()
	)


func _get_fallback_card(owner: SlotRow.SlotOwner, mutation: Mutation) -> CardRoot:
	if selection_state != null:
		var selected := selection_state.get_selected_card(owner)

		if selected != null and selected.can_receive_buff_mutation(mutation):
			return selected

	if root == null:
		return null

	if root.deck_system_root == null:
		return null

	var hand := root.deck_system_root.get_hand_for_owner(owner)

	if hand == null:
		return null

	var valid_cards: Array[CardRoot] = []

	for card: CardRoot in hand.get_cards():
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if not card.can_receive_buff_mutation(mutation):
			continue

		valid_cards.append(card)

	if valid_cards.is_empty():
		return null

	return valid_cards.pick_random()


func _finish_buff_phase() -> void:
	if root.buff_flow_handler != null:
		root.buff_flow_handler.finish_buff_flow()

	confirmed_owners.clear()
