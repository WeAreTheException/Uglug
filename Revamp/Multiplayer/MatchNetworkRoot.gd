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

@export var lookup_network: MatchNetworkLookup
@export var draw_network: MatchNetworkDraw
@export var buff_network: MatchNetworkBuff
@export var blessing_network: MatchNetworkBlessing
@export var placement_network: MatchNetworkPlacement
@export var flow_network: MatchNetworkFlow

@export var enable_match_advance_debug := true
@export var match_advance_debug_key: Key = KEY_M
@export var enable_ping_debug := false
@export var ping_debug_key: Key = KEY_N
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
	GDSync.expose_func(request_advance_match_state)
	GDSync.expose_func(_receive_match_state_snapshot)
	GDSync.expose_func(_receive_blessing_flow_finished)
	GDSync.expose_func(_receive_buff_flow_finished)

	_setup_children()
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

	if enable_ping_debug and key_event.keycode == ping_debug_key:
		_send_ping_debug()

	if lookup_network != null:
		lookup_network.handle_debug_input(key_event)

	if draw_network != null:
		draw_network.handle_debug_input(key_event)
	
	if enable_match_advance_debug and key_event.keycode == match_advance_debug_key:
		request_advance_match_state()


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
	if draw_network == null:
		print("REQUEST DRAW FAILED: draw_network missing")
		return

	draw_network.request_draw(owner, pile_type)


func _receive_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String
) -> void:
	if draw_network == null:
		print("CONFIRMED DRAW FAILED: draw_network missing")
		return

	draw_network.receive_confirmed_draw(owner, card_id, runtime_id, pile_type)


func request_buff_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if buff_network == null:
		print("REQUEST BUFF FAILED: buff_network missing")
		return

	buff_network.request_buff_confirm(owner, target_card_runtime_id, mutation_id)


func _receive_buff_reward(mutation_id: String) -> void:
	if buff_network == null:
		print("BUFF RECEIVE FAILED: buff_network missing")
		return

	buff_network.receive_buff_reward(mutation_id)


func _receive_confirmed_buff(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	mutation_id: String
) -> void:
	if buff_network == null:
		print("CONFIRMED BUFF FAILED: buff_network missing")
		return

	buff_network.receive_confirmed_buff(owner, target_card_runtime_id, mutation_id)


func request_blessing_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if blessing_network == null:
		print("REQUEST BLESSING FAILED: blessing_network missing")
		return

	blessing_network.request_blessing_confirm(
		owner,
		target_card_runtime_id,
		blessing_id
	)


func _receive_confirmed_blessing(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if blessing_network == null:
		print("CONFIRMED BLESSING FAILED: blessing_network missing")
		return

	blessing_network.receive_confirmed_blessing(
		owner,
		target_card_runtime_id,
		blessing_id
	)


func request_placement(payload: Dictionary) -> void:
	if placement_network == null:
		print("REQUEST PLACEMENT FAILED: placement_network missing")
		return

	placement_network.request_placement(payload)


func _receive_confirmed_placement(payload: Dictionary) -> void:
	if placement_network == null:
		print("CONFIRMED PLACEMENT FAILED: placement_network missing")
		return

	placement_network.receive_confirmed_placement(payload)


func find_card_anywhere(runtime_id: String) -> CardRoot:
	if lookup_network == null:
		return null

	return lookup_network.find_card_anywhere(runtime_id)


func get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if lookup_network != null:
		return lookup_network.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"


func _setup_children() -> void:
	if lookup_network != null:
		lookup_network.setup(self)

	if draw_network != null:
		draw_network.setup(self)

	if buff_network != null:
		buff_network.setup(self)

	if blessing_network != null:
		blessing_network.setup(self)

	if placement_network != null:
		placement_network.setup(self)
	
	if flow_network != null:
		flow_network.setup(self)


func _connect_match_flow() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if not is_host():
		return

	if state == MatchFlowRoot.MatchState.BUFF:
		if buff_network != null:
			buff_network.on_buff_phase_started()


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


func _send_ping_debug() -> void:
	print("NETWORK PING SENDING")

	GDSync.call_func_all(
		_receive_network_ping,
		"hello from " + str(GDSync.get_client_id())
	)


func _receive_network_ping(message: String) -> void:
	print("NETWORK PING RECEIVED: ", message, " | HOST: ", is_host())


func request_advance_match_state() -> void:
	if flow_network == null:
		print("REQUEST MATCH ADVANCE FAILED: flow_network missing")
		return

	flow_network.request_advance_match_state()


func _receive_match_state_snapshot(payload: Dictionary) -> void:
	if flow_network == null:
		print("MATCH SNAPSHOT RECEIVE FAILED: flow_network missing")
		return

	flow_network.receive_match_state_snapshot(payload)

func _receive_blessing_flow_finished() -> void:
	if blessing_network == null:
		return

	blessing_network.receive_blessing_flow_finished()


func _receive_buff_flow_finished() -> void:
	if buff_network == null:
		return

	buff_network.receive_buff_flow_finished()
