extends Node
class_name MatchNetworkDraw

@export var enable_draw_debug := false
@export var draw_debug_key: Key = KEY_D
@export var debug_draw_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var debug_draw_pile_type := DeckSystemRoot.DRAW_PILE_WARRIOR

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func handle_debug_input(key_event: InputEventKey) -> void:
	if not enable_draw_debug:
		return

	if key_event.keycode == draw_debug_key:
		request_draw(debug_draw_owner, debug_draw_pile_type)


func request_draw(
	owner: SlotRow.SlotOwner,
	pile_type: String,
	inherit_mutation_ids: Array[String] = []
) -> void:
	if root == null:
		return

	if root.is_host():
		_process_draw_request(owner, pile_type, inherit_mutation_ids)
		return

	GDSync.call_func(root.request_draw, owner, pile_type, inherit_mutation_ids)


func receive_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String,
	inherit_mutation_ids: Array[String] = []
) -> void:
	if root == null:
		return

	print(
		"CONFIRMED DRAW RECEIVED: ",
		root.get_owner_name(owner),
		" ",
		pile_type,
		" ",
		card_id,
		" inherit=",
		inherit_mutation_ids,
		" | HOST: ",
		root.is_host(),
		" | SETUP READY: ",
		root.has_received_setup_payload
	)

	if not root.has_received_setup_payload:
		print("CONFIRMED DRAW IGNORED: setup payload not ready")
		return

	if root.deck_system_root == null:
		print("CONFIRMED DRAW FAILED: deck_system_root missing")
		return

	root.deck_system_root.apply_confirmed_draw(
		owner,
		card_id,
		runtime_id,
		pile_type,
		not root.is_host(),
		inherit_mutation_ids
	)


func _process_draw_request(
	owner: SlotRow.SlotOwner,
	pile_type: String,
	inherit_mutation_ids: Array[String] = []
) -> void:
	if root.deck_system_root == null:
		print("DRAW REQUEST REJECTED: deck_system_root missing")
		return

	if not _is_valid_draw_request(pile_type):
		return

	var entry := root.deck_system_root.pop_draw_entry_for_owner(owner, pile_type)

	if entry.is_empty():
		print("DRAW REQUEST REJECTED: empty draw result")
		return

	var card_id: String = entry.get("card_id", "")
	var runtime_id: String = entry.get("runtime_id", "")

	_broadcast_confirmed_draw(
		owner,
		card_id,
		runtime_id,
		pile_type,
		inherit_mutation_ids
	)


func _is_valid_draw_request(pile_type: String) -> bool:
	if pile_type != DeckSystemRoot.DRAW_PILE_WARRIOR:
		if pile_type != DeckSystemRoot.DRAW_PILE_WORKER:
			print("DRAW REQUEST REJECTED: bad pile type ", pile_type)
			return false

	if root.match_flow_root == null:
		return true

	if root.match_flow_root.current_state != MatchFlowRoot.MatchState.AUTO_DRAW:
		if root.print_debug:
			print("DRAW REQUEST WARNING: draw outside AUTO_DRAW")

	return true


func _broadcast_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String,
	inherit_mutation_ids: Array[String] = []
) -> void:
	if root.print_debug:
		print(
			"DRAW CONFIRMED: ",
			root.get_owner_name(owner),
			" ",
			pile_type,
			" ",
			card_id,
			" ",
			runtime_id,
			" inherit=",
			inherit_mutation_ids
		)

	GDSync.call_func_all(
		root._receive_confirmed_draw,
		owner,
		card_id,
		runtime_id,
		pile_type,
		inherit_mutation_ids
	)
