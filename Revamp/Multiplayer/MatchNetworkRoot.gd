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

@export var print_debug := true

var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER


func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(_receive_match_setup_payload)
	GDSync.expose_func(_receive_network_ping)

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


func is_host() -> bool:
	return GDSync.is_host()


func is_client() -> bool:
	return not GDSync.is_host()


func get_local_client_id() -> int:
	return GDSync.get_client_id()


func get_local_owner() -> SlotRow.SlotOwner:
	return local_owner


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
