extends Node
class_name MatchManualDrawHandler

@export var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var max_draws_per_player: int = 2
@export var print_debug: bool = true

var worker_button: BaseButton = null
var warrior_button: BaseButton = null
var deck_system_root: DeckSystemRoot = null
var match_network_root: MatchNetworkRoot = null
var match_flow_root: MatchFlowRoot = null

var confirmed_draw_count: int = 0
var pending_draw_count: int = 0


func setup(
	new_worker_button: BaseButton,
	new_warrior_button: BaseButton,
	new_deck_system_root: DeckSystemRoot
) -> void:
	_disconnect_buttons()

	worker_button = new_worker_button
	warrior_button = new_warrior_button
	deck_system_root = new_deck_system_root

	if worker_button != null:
		worker_button.pressed.connect(
			_on_worker_pressed
		)

	if warrior_button != null:
		warrior_button.pressed.connect(
			_on_warrior_pressed
		)

	call_deferred("_connect_runtime_signals")
	_refresh_buttons()

	if print_debug:
		print("MANUAL DRAW SETUP")


func _connect_runtime_signals() -> void:
	if deck_system_root == null:
		print("MANUAL DRAW BLOCKED: DeckSystemRoot missing")
		return

	match_network_root = deck_system_root.match_network_root

	if match_network_root == null:
		if print_debug:
			print("MANUAL DRAW LOCAL MODE")

		_refresh_buttons()
		return

	match_flow_root = match_network_root.match_flow_root

	if match_flow_root == null:
		print("MANUAL DRAW BLOCKED: MatchFlowRoot missing")
	else:
		if not match_flow_root.match_state_changed.is_connected(
			_on_match_state_changed
		):
			match_flow_root.match_state_changed.connect(
				_on_match_state_changed
			)

	if match_network_root.draw_network == null:
		print("MANUAL DRAW BLOCKED: MatchNetworkDraw missing")
	else:
		if not match_network_root.draw_network.confirmed_draw_applied.is_connected(
			_on_confirmed_draw_applied
		):
			match_network_root.draw_network.confirmed_draw_applied.connect(
				_on_confirmed_draw_applied
			)

	if print_debug:
		print(
			"MANUAL DRAW CONNECTED | OWNER: ",
			_get_owner_name(_get_local_owner()),
			" | PHASE: ",
			_get_current_phase_name()
		)

	_refresh_buttons()


func _on_worker_pressed() -> void:
	_request_draw(
		DeckSystemRoot.DRAW_PILE_WORKER
	)


func _on_warrior_pressed() -> void:
	_request_draw(
		DeckSystemRoot.DRAW_PILE_WARRIOR
	)


func _request_draw(pile_type: String) -> void:
	if deck_system_root == null:
		print("MANUAL DRAW BLOCKED: DeckSystemRoot missing")
		return

	if not _is_draw_phase():
		if print_debug:
			print(
				"MANUAL DRAW BLOCKED: phase is ",
				_get_current_phase_name()
			)
		return

	if (
		confirmed_draw_count + pending_draw_count
		>= max_draws_per_player
	):
		if print_debug:
			print("MANUAL DRAW BLOCKED: draw limit reached")
		return

	pending_draw_count += 1
	_refresh_buttons()

	if match_network_root != null:
		match_network_root.request_draw(
			_get_local_owner(),
			pile_type,
			[]
		)
	else:
		_draw_locally(pile_type)

	if print_debug:
		print(
			"MANUAL DRAW REQUESTED: ",
			pile_type,
			" | OWNER: ",
			_get_owner_name(_get_local_owner()),
			" | CONFIRMED: ",
			confirmed_draw_count,
			" | PENDING: ",
			pending_draw_count
		)


func _draw_locally(pile_type: String) -> void:
	if pile_type == DeckSystemRoot.DRAW_PILE_WORKER:
		deck_system_root.draw_worker_for_owner(
			local_owner
		)
	else:
		deck_system_root.draw_warrior_for_owner(
			local_owner
		)

	pending_draw_count = max(
		pending_draw_count - 1,
		0
	)

	confirmed_draw_count += 1
	_refresh_buttons()


func _on_confirmed_draw_applied(
	owner: SlotRow.SlotOwner,
	card: CardRoot,
	pile_type: String
) -> void:
	if owner != _get_local_owner():
		return

	if not _is_draw_phase():
		return

	if pending_draw_count > 0:
		pending_draw_count -= 1

	confirmed_draw_count = min(
		confirmed_draw_count + 1,
		max_draws_per_player
	)

	if print_debug:
		print(
			"MANUAL DRAW CONFIRMED: ",
			card.card_name,
			" | PILE: ",
			pile_type,
			" | OWNER: ",
			_get_owner_name(owner),
			" | COUNT: ",
			confirmed_draw_count,
			"/",
			max_draws_per_player
		)

	_refresh_buttons()


func _on_match_state_changed(
	state: MatchFlowRoot.MatchState
) -> void:
	if state == MatchFlowRoot.MatchState.AUTO_DRAW:
		confirmed_draw_count = 0
		pending_draw_count = 0
	else:
		pending_draw_count = 0

	if print_debug:
		print(
			"MANUAL DRAW PHASE CHANGED: ",
			match_flow_root.get_state_name(state)
		)

	_refresh_buttons()


func _refresh_buttons() -> void:
	var draw_phase_active := _is_draw_phase()

	var can_draw := (
		draw_phase_active
		and confirmed_draw_count + pending_draw_count
		< max_draws_per_player
	)

	_set_button_state(
		worker_button,
		draw_phase_active,
		can_draw
	)

	_set_button_state(
		warrior_button,
		draw_phase_active,
		can_draw
	)

	if print_debug:
		print(
			"MANUAL DRAW BUTTONS | VISIBLE: ",
			draw_phase_active,
			" | ENABLED: ",
			can_draw,
			" | CONFIRMED: ",
			confirmed_draw_count,
			" | PENDING: ",
			pending_draw_count
		)


func _set_button_state(
	button: BaseButton,
	should_be_visible: bool,
	should_be_enabled: bool
) -> void:
	if button == null:
		return

	button.visible = should_be_visible
	button.disabled = not should_be_enabled


func _is_draw_phase() -> bool:
	if match_flow_root == null:
		return false

	return (
		match_flow_root.current_state
		== MatchFlowRoot.MatchState.AUTO_DRAW
	)


func _get_local_owner() -> SlotRow.SlotOwner:
	if match_network_root != null:
		return match_network_root.get_local_owner()

	return local_owner


func _get_owner_name(
	owner: SlotRow.SlotOwner
) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"


func _get_current_phase_name() -> String:
	if match_flow_root == null:
		return "MISSING"

	return match_flow_root.get_state_name(
		match_flow_root.current_state
	)


func _disconnect_buttons() -> void:
	if (
		worker_button != null
		and worker_button.pressed.is_connected(
			_on_worker_pressed
		)
	):
		worker_button.pressed.disconnect(
			_on_worker_pressed
		)

	if (
		warrior_button != null
		and warrior_button.pressed.is_connected(
			_on_warrior_pressed
		)
	):
		warrior_button.pressed.disconnect(
			_on_warrior_pressed
		)
