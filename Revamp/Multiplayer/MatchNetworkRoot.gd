extends Node
class_name MatchNetworkRoot

@export var match_flow_root: MatchFlowRoot
@export var deck_system_root: DeckSystemRoot
@export var turn_order_state: MatchTurnOrderState
@export var match_score_state: MatchScoreState
@export var slots_root: SlotsRoot

@export var buff_flow_handler: BuffFlowHandler
@export var buff_database: BuffDatabase
@export var blessing_flow_handler: BlessingFlowHandler
@export var placement_controller: PlacementController

@export var enable_lookup_debug := false
@export var lookup_debug_key: Key = KEY_L

@export var enable_ping_debug := false
@export var ping_debug_key: Key = KEY_N

@export var enable_draw_debug := false
@export var draw_debug_key: Key = KEY_D
@export var debug_draw_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var debug_draw_pile_type := DeckSystemRoot.DRAW_PILE_WARRIOR

@export var print_debug := true

var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var has_received_setup_payload := false


func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(_receive_match_setup_payload)
	GDSync.expose_func(_receive_network_ping)
	GDSync.expose_func(request_draw)
	GDSync.expose_func(_receive_confirmed_draw)
	GDSync.expose_func(_receive_buff_reward)
	GDSync.expose_func(request_buff_confirm)
	GDSync.expose_func(_receive_confirmed_buff)
	GDSync.expose_func(request_blessing_confirm)
	GDSync.expose_func(_receive_confirmed_blessing)
	GDSync.expose_func(request_placement)
	GDSync.expose_func(_receive_confirmed_placement)

	_assign_local_owner()
	_print_network_status()
	_connect_deck_setup()
	_connect_match_flow()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if enable_lookup_debug and key_event.keycode == lookup_debug_key:
		_run_lookup_debug()

	if enable_ping_debug and key_event.keycode == ping_debug_key:
		_send_ping_debug()

	if enable_draw_debug and key_event.keycode == draw_debug_key:
		request_draw(debug_draw_owner, debug_draw_pile_type)


func is_host() -> bool:
	return GDSync.is_host()


func is_client() -> bool:
	return not GDSync.is_host()


func get_local_client_id() -> int:
	return GDSync.get_client_id()


func get_local_owner() -> SlotRow.SlotOwner:
	return local_owner


func request_draw(
	owner: SlotRow.SlotOwner,
	pile_type: String
) -> void:
	if is_host():
		_process_draw_request(owner, pile_type)
		return

	GDSync.call_func(request_draw, owner, pile_type)


func request_buff_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if is_host():
		_process_buff_confirm_request(owner, target_card_runtime_id, mutation_id)
		return

	GDSync.call_func(
		request_buff_confirm,
		owner,
		target_card_runtime_id,
		mutation_id
	)


func request_blessing_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if is_host():
		_process_blessing_confirm_request(
			owner,
			target_card_runtime_id,
			blessing_id
		)
		return

	GDSync.call_func(
		request_blessing_confirm,
		owner,
		target_card_runtime_id,
		blessing_id
	)


func request_placement(payload: Dictionary) -> void:
	print(
		"REQUEST PLACEMENT CALLED | HOST: ",
		is_host(),
		" payload: ",
		payload
	)

	if is_host():
		_process_placement_request(payload)
		return

	GDSync.call_func(request_placement, payload)


func find_card_anywhere(runtime_id: String) -> CardRoot:
	var clean_id := runtime_id.strip_edges()

	if clean_id == "":
		return null

	if deck_system_root != null:
		var card := _find_card_in_hand(deck_system_root.player_one_hand, clean_id)

		if card != null:
			return card

		card = _find_card_in_hand(deck_system_root.player_two_hand, clean_id)

		if card != null:
			return card

	if slots_root != null:
		return slots_root.find_card_by_runtime_id(clean_id)

	return null


func _connect_match_flow() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BUFF:
		_on_buff_phase_started()


func _on_buff_phase_started() -> void:
	if not is_host():
		return

	if buff_database == null:
		print("HOST BUFF ROLL BLOCKED: buff_database missing")
		return

	var mutation := buff_database.draw_random_mutation()

	if mutation == null:
		print("HOST BUFF ROLL BLOCKED: no mutation")
		return

	var mutation_id := mutation.get_safe_mutation_id()

	if print_debug:
		print("HOST BUFF ROLLED: ", mutation_id)

	GDSync.call_func_all(_receive_buff_reward, mutation_id)


func _receive_buff_reward(mutation_id: String) -> void:
	if buff_database == null:
		print("BUFF RECEIVE FAILED: buff_database missing")
		return

	if buff_flow_handler == null:
		print("BUFF RECEIVE FAILED: buff_flow_handler missing")
		return

	var mutation := buff_database.get_mutation_by_id(mutation_id)

	if mutation == null:
		print("BUFF RECEIVE FAILED: ", mutation_id)
		return

	if print_debug:
		print("BUFF RECEIVE: ", mutation.mutation_name, " | HOST: ", is_host())

	buff_flow_handler.begin_buff_flow_with_reward(mutation)


func _process_buff_confirm_request(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if buff_database == null:
		print("BUFF REQUEST REJECTED: buff_database missing")
		return

	var card := find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("BUFF REQUEST REJECTED: card missing ", target_card_runtime_id)
		return

	if not _card_belongs_to_owner_hand(card, owner):
		print("BUFF REQUEST REJECTED: wrong owner")
		return

	var mutation := buff_database.get_mutation_by_id(mutation_id)

	if mutation == null:
		print("BUFF REQUEST REJECTED: mutation missing ", mutation_id)
		return

	if buff_flow_handler != null:
		var offered := buff_flow_handler.get_active_reward_mutation()

		if offered != null and offered.get_safe_mutation_id() != mutation_id:
			print("BUFF REQUEST REJECTED: mutation was not offered")
			return

	if not card.can_receive_buff_mutation(mutation):
		print("BUFF REQUEST REJECTED: card cannot receive mutation")
		return

	_broadcast_confirmed_buff(owner, target_card_runtime_id, mutation_id)


func _broadcast_confirmed_buff(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if print_debug:
		print(
			"BUFF CONFIRMED: ",
			_get_owner_name(owner),
			" ",
			target_card_runtime_id,
			" ",
			mutation_id
		)

	GDSync.call_func_all(
		_receive_confirmed_buff,
		owner,
		target_card_runtime_id,
		mutation_id
	)


func _receive_confirmed_buff(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if buff_database == null:
		print("CONFIRMED BUFF FAILED: buff_database missing")
		return

	var card := find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("CONFIRMED BUFF FAILED: card missing ", target_card_runtime_id)
		return

	var mutation := buff_database.get_mutation_by_id(mutation_id)

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

	if print_debug:
		print(
			"CONFIRMED BUFF APPLIED: ",
			_get_owner_name(owner),
			" ",
			mutation.mutation_name,
			" -> ",
			card.card_name
		)


func _process_blessing_confirm_request(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	var card := find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("BLESSING REQUEST REJECTED: card missing ", target_card_runtime_id)
		return

	if not _card_belongs_to_owner_hand(card, owner):
		print("BLESSING REQUEST REJECTED: wrong owner")
		return

	var blessing := _get_active_blessing_by_id(blessing_id)

	if blessing == null:
		print("BLESSING REQUEST REJECTED: blessing missing ", blessing_id)
		return

	_broadcast_confirmed_blessing(owner, target_card_runtime_id, blessing_id)


func _broadcast_confirmed_blessing(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if print_debug:
		print(
			"BLESSING CONFIRMED: ",
			_get_owner_name(owner),
			" ",
			target_card_runtime_id,
			" ",
			blessing_id
		)

	GDSync.call_func_all(
		_receive_confirmed_blessing,
		owner,
		target_card_runtime_id,
		blessing_id
	)


func _receive_confirmed_blessing(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	var card := find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("CONFIRMED BLESSING FAILED: card missing ", target_card_runtime_id)
		return

	var blessing := _get_active_blessing_by_id(blessing_id)

	if blessing == null:
		print("CONFIRMED BLESSING FAILED: blessing missing ", blessing_id)
		return

	print("CONFIRMED BLESSING ABOUT TO APPLY: ", blessing_id)

	var applied := BlessingApplyHelper.new().apply_blessing(
		card,
		blessing
	)

	if not applied:
		print("CONFIRMED BLESSING FAILED: apply failed")
		return

	if print_debug:
		print(
			"CONFIRMED BLESSING APPLIED: ",
			_get_owner_name(owner),
			" ",
			blessing.get_display_name(),
			" -> ",
			card.card_name
		)


func _get_active_blessing_by_id(blessing_id: String) -> Blessing:
	if blessing_flow_handler == null:
		return null

	var blessing := blessing_flow_handler.get_active_blessing()

	if blessing == null:
		return null

	var clean_id := blessing_id.strip_edges().to_snake_case()
	var active_id := blessing.blessing_id.strip_edges().to_snake_case()

	if active_id != clean_id:
		return null

	return blessing


func _process_draw_request(
	owner: SlotRow.SlotOwner,
	pile_type: String
) -> void:
	if deck_system_root == null:
		print("DRAW REQUEST REJECTED: deck_system_root missing")
		return

	if not _is_valid_draw_request(owner, pile_type):
		return

	var entry := deck_system_root.pop_draw_entry_for_owner(owner, pile_type)

	if entry.is_empty():
		print("DRAW REQUEST REJECTED: empty draw result")
		return

	var card_id: String = entry.get("card_id", "")
	var runtime_id: String = entry.get("runtime_id", "")

	_broadcast_confirmed_draw(owner, card_id, runtime_id, pile_type)


func _is_valid_draw_request(
	owner: SlotRow.SlotOwner,
	pile_type: String
) -> bool:
	if pile_type != DeckSystemRoot.DRAW_PILE_WARRIOR:
		if pile_type != DeckSystemRoot.DRAW_PILE_WORKER:
			print("DRAW REQUEST REJECTED: bad pile type ", pile_type)
			return false

	if match_flow_root == null:
		return true

	if match_flow_root.current_state != MatchFlowRoot.MatchState.AUTO_DRAW:
		if print_debug:
			print("DRAW REQUEST WARNING: draw outside AUTO_DRAW")

	return true


func _broadcast_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String
) -> void:
	if print_debug:
		print(
			"DRAW CONFIRMED: ",
			_get_owner_name(owner),
			" ",
			pile_type,
			" ",
			card_id,
			" ",
			runtime_id
		)

	GDSync.call_func_all(
		_receive_confirmed_draw,
		owner,
		card_id,
		runtime_id,
		pile_type
	)


func _receive_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String
) -> void:
	print(
		"CONFIRMED DRAW RECEIVED: ",
		_get_owner_name(owner),
		" ",
		pile_type,
		" ",
		card_id,
		" | HOST: ",
		is_host(),
		" | SETUP READY: ",
		has_received_setup_payload
	)

	if not has_received_setup_payload:
		print("CONFIRMED DRAW IGNORED: setup payload not ready")
		return

	if deck_system_root == null:
		print("CONFIRMED DRAW FAILED: deck_system_root missing")
		return

	deck_system_root.apply_confirmed_draw(
		owner,
		card_id,
		runtime_id,
		pile_type,
		not is_host()
	)


func _process_placement_request(payload: Dictionary) -> void:
	print("PLACEMENT REQUEST RECEIVED: ", payload)

	if not _is_valid_placement_request(payload):
		print("PLACEMENT REQUEST REJECTED")
		return

	_broadcast_confirmed_placement(payload)


func _is_valid_placement_request(payload: Dictionary) -> bool:
	if payload.is_empty():
		print("PLACEMENT VALIDATION FAILED: payload empty")
		return false

	var owner: SlotRow.SlotOwner = payload.get("owner", SlotRow.SlotOwner.PLAYER)
	var card_id: String = payload.get("placed_card_runtime_id", "")
	var slot_owner: SlotRow.SlotOwner = payload.get("target_slot_owner", SlotRow.SlotOwner.PLAYER)
	var slot_index: int = payload.get("target_slot_index", -1)

	var card := find_card_anywhere(card_id)

	if card == null:
		print("PLACEMENT VALIDATION FAILED: card missing ", card_id)
		return false

	if not _card_belongs_to_owner_hand(card, owner):
		print("PLACEMENT VALIDATION FAILED: card wrong owner")
		return false

	if slots_root == null:
		print("PLACEMENT VALIDATION FAILED: slots_root missing")
		return false

	var slot := slots_root.get_slot(slot_owner, slot_index)

	if slot == null:
		print("PLACEMENT VALIDATION FAILED: slot missing")
		return false

	if not slot.is_empty():
		print("PLACEMENT VALIDATION FAILED: slot occupied")
		return false

	return true


func _broadcast_confirmed_placement(payload: Dictionary) -> void:
	if print_debug:
		print("PLACEMENT CONFIRMED: ", payload)

	GDSync.call_func_all(_receive_confirmed_placement, payload)


func _receive_confirmed_placement(payload: Dictionary) -> void:
	if placement_controller == null:
		print("CONFIRMED PLACEMENT FAILED: placement_controller missing")
		return

	placement_controller.apply_confirmed_placement(payload)


func _assign_local_owner() -> void:
	if is_host():
		local_owner = SlotRow.SlotOwner.PLAYER
	else:
		local_owner = SlotRow.SlotOwner.OPPONENT

	if turn_order_state != null:
		turn_order_state.set_controlled_owner(local_owner)


func _print_network_status() -> void:
	if not print_debug:
		return

	if is_host():
		print("MATCH NETWORK: HOST")
		print("LOCAL OWNER: P1")
	else:
		print("MATCH NETWORK: CLIENT")
		print("LOCAL OWNER: P2")


func _connect_deck_setup() -> void:
	if deck_system_root == null:
		return

	if not deck_system_root.starting_hands_dealt.is_connected(_on_starting_hands_dealt):
		deck_system_root.starting_hands_dealt.connect(_on_starting_hands_dealt)

	if is_host():
		_try_broadcast_existing_setup_payload()


func _try_broadcast_existing_setup_payload() -> void:
	if deck_system_root == null:
		return

	var payload := deck_system_root.get_last_setup_payload()

	if payload.is_empty():
		return

	_broadcast_match_setup_payload(payload)


func _on_starting_hands_dealt() -> void:
	if not is_host():
		return

	if deck_system_root == null:
		return

	var payload := deck_system_root.get_last_setup_payload()

	if payload.is_empty():
		print("MATCH SETUP BROADCAST FAILED: payload empty")
		return

	_broadcast_match_setup_payload(payload)


func _broadcast_match_setup_payload(payload: Dictionary) -> void:
	has_received_setup_payload = true

	if print_debug:
		print("MATCH SETUP READY: HOST")

	GDSync.call_func_all(_receive_match_setup_payload, payload)


func _receive_match_setup_payload(payload: Dictionary) -> void:
	if is_host():
		return

	if deck_system_root == null:
		print("MATCH SETUP APPLY FAILED: deck_system_root missing")
		return

	deck_system_root.apply_match_setup_payload(payload)
	has_received_setup_payload = true
	print("MATCH SETUP READY: CLIENT")


func _card_belongs_to_owner_hand(
	card: CardRoot,
	owner: SlotRow.SlotOwner
) -> bool:
	if deck_system_root == null:
		return false

	var hand := deck_system_root.get_hand_for_owner(owner)

	if hand == null:
		return false

	return hand.has_card(card)


func _find_card_in_hand(
	hand: PlayerHandRoot,
	runtime_id: String
) -> CardRoot:
	if hand == null:
		return null

	return hand.find_card_by_runtime_id(runtime_id)


func _send_ping_debug() -> void:
	print("NETWORK PING SENDING")

	GDSync.call_func_all(
		_receive_network_ping,
		"hello from " + str(GDSync.get_client_id())
	)


func _receive_network_ping(message: String) -> void:
	print("NETWORK PING RECEIVED: ", message, " | HOST: ", is_host())


func _run_lookup_debug() -> void:
	if deck_system_root == null:
		print("LOOKUP DEBUG FAILED: deck_system_root missing")
		return

	var hand := deck_system_root.player_one_hand

	if hand == null:
		print("LOOKUP DEBUG FAILED: P1 hand missing")
		return

	if hand.card_spawner == null:
		print("LOOKUP DEBUG FAILED: P1 card_spawner missing")
		return

	var cards := hand.card_spawner.get_cards()

	if cards.is_empty():
		print("LOOKUP DEBUG FAILED: P1 hand empty")
		return

	var first_card: CardRoot = cards[0]
	var runtime_id := first_card.get_runtime_id()
	var found_card := find_card_anywhere(runtime_id)

	print("LOOKUP DEBUG ID: ", runtime_id)
	print("LOOKUP DEBUG FOUND: ", found_card == first_card)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if turn_order_state != null:
		return turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
