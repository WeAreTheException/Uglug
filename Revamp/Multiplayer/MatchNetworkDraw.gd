extends Node
class_name MatchNetworkDraw

signal confirmed_draw_applied(
	owner: SlotRow.SlotOwner,
	card: CardRoot,
	pile_type: String
)

@export var enable_draw_debug := false
@export var draw_debug_key: Key = KEY_D

@export var debug_draw_owner: SlotRow.SlotOwner = (
	SlotRow.SlotOwner.PLAYER
)

@export var debug_draw_pile_type := (
	DeckSystemRoot.DRAW_PILE_WARRIOR
)

@export var print_debug: bool = false

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func handle_debug_input(
	key_event: InputEventKey
) -> void:
	if not enable_draw_debug:
		return

	if key_event.keycode != draw_debug_key:
		return

	request_draw({
		"owner": int(debug_draw_owner),
		"pile_type": debug_draw_pile_type,
		"inherit_mutation_ids": []
	})


func request_draw(payload: Dictionary) -> void:
	if root == null:
		return

	if root.is_host():
		_process_draw_request(payload)
		return

	var owner: SlotRow.SlotOwner = int(
		payload.get(
			"owner",
			SlotRow.SlotOwner.PLAYER
		)
	) as SlotRow.SlotOwner

	var pile_type: String = str(
		payload.get(
			"pile_type",
			""
		)
	)

	var inherit_mutation_ids: Array[String] = (
		_to_string_array(
			payload.get(
				"inherit_mutation_ids",
				[]
			)
		)
	)

	GDSync.call_func(
		root.request_draw,
		owner,
		pile_type,
		inherit_mutation_ids
	)


func receive_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String,
	inherit_mutation_ids: Array[String] = []
) -> void:
	if root == null:
		return

	if print_debug:
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
		print(
			"CONFIRMED DRAW IGNORED: "
			+ "setup payload not ready"
		)
		return

	if root.deck_system_root == null:
		print(
			"CONFIRMED DRAW FAILED: "
			+ "deck_system_root missing"
		)
		return

	var card: CardRoot = (
		root.deck_system_root.apply_confirmed_draw(
			owner,
			card_id,
			runtime_id,
			pile_type,
			not root.is_host(),
			inherit_mutation_ids
		)
	)

	if card == null:
		return

	confirmed_draw_applied.emit(
		owner,
		card,
		pile_type
	)


func _process_draw_request(
	payload: Dictionary
) -> void:
	if root == null:
		return

	if root.deck_system_root == null:
		print(
			"DRAW REQUEST REJECTED: "
			+ "deck_system_root missing"
		)
		return

	if payload.is_empty():
		print(
			"DRAW REQUEST REJECTED: payload empty"
		)
		return

	var owner: SlotRow.SlotOwner = int(
		payload.get(
			"owner",
			SlotRow.SlotOwner.PLAYER
		)
	) as SlotRow.SlotOwner

	var pile_type: String = str(
		payload.get(
			"pile_type",
			""
		)
	)

	var inherit_mutation_ids: Array[String] = (
		_to_string_array(
			payload.get(
				"inherit_mutation_ids",
				[]
			)
		)
	)

	if not _is_valid_draw_request(pile_type):
		return

	var entry: Dictionary = (
		root.deck_system_root
		.pop_draw_entry_for_owner(
			owner,
			pile_type
		)
	)

	if entry.is_empty():
		print(
			"DRAW REQUEST REJECTED: "
			+ "empty draw result"
		)
		return

	var card_id: String = str(
		entry.get(
			"card_id",
			""
		)
	)

	var runtime_id: String = str(
		entry.get(
			"runtime_id",
			""
		)
	)

	_broadcast_confirmed_draw(
		owner,
		card_id,
		runtime_id,
		pile_type,
		inherit_mutation_ids
	)


func _is_valid_draw_request(
	pile_type: String
) -> bool:
	if (
		pile_type
		!= DeckSystemRoot.DRAW_PILE_WARRIOR
		and pile_type
		!= DeckSystemRoot.DRAW_PILE_WORKER
	):
		print(
			"DRAW REQUEST REJECTED: "
			+ "bad pile type ",
			pile_type
		)
		return false

	if root == null:
		return false

	if root.match_flow_root == null:
		return true

	if (
		root.match_flow_root.current_state
		!= MatchFlowRoot.MatchState.AUTO_DRAW
	):
		if root.print_debug and print_debug:
			print(
				"DRAW REQUEST WARNING: "
				+ "draw outside AUTO_DRAW"
			)

	return true


func _broadcast_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String,
	inherit_mutation_ids: Array[String] = []
) -> void:
	if root == null:
		return

	if root.print_debug and print_debug:
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


func _to_string_array(
	source: Array
) -> Array[String]:
	var result: Array[String] = []

	for item in source:
		var value: String = str(item).strip_edges()

		if value == "":
			continue

		result.append(value)

	return result
