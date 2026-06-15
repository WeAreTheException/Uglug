extends Node
class_name MatchNetworkRoot

@export var match_flow_root: MatchFlowRoot
@export var deck_system_root: DeckSystemRoot
@export var turn_order_state: MatchTurnOrderState
@export var match_score_state: MatchScoreState
@export var slots_root: SlotsRoot

@export var enable_lookup_debug := false
@export var lookup_debug_key: Key = KEY_L

@export var enable_ping_debug := false
@export var ping_debug_key: Key = KEY_N

@export var enable_draw_debug := false
@export var draw_debug_key: Key = KEY_D
@export var debug_draw_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var debug_draw_pile_type := "warrior"

@export var print_debug := true

var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var has_broadcast_setup_payload := false


func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(_receive_match_setup_payload)
	GDSync.expose_func(_receive_network_ping)
	GDSync.expose_func(request_draw)
	GDSync.expose_func(_receive_confirmed_draw)

	_assign_local_owner()
	_print_network_status()
	_connect_deck_setup()


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
	if has_broadcast_setup_payload:
		return

	if deck_system_root == null:
		return

	var payload := deck_system_root.get_last_setup_payload()

	if payload.is_empty():
		return

	_broadcast_match_setup_payload(payload)


func _on_starting_hands_dealt() -> void:
	if not is_host():
		return

	if has_broadcast_setup_payload:
		return

	if deck_system_root == null:
		return

	var payload := deck_system_root.get_last_setup_payload()

	if payload.is_empty():
		print("MATCH SETUP BROADCAST FAILED: payload empty")
		return

	_broadcast_match_setup_payload(payload)


func _broadcast_match_setup_payload(payload: Dictionary) -> void:
	has_broadcast_setup_payload = true

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
	print("MATCH SETUP READY: CLIENT")


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
