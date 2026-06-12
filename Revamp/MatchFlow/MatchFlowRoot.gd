extends Node
class_name MatchFlowRoot

signal match_state_changed(state: MatchState)
signal round_changed(round_number: int)

enum MatchState {
	NONE,
	ROUND_INTRO,
	AUTO_DRAW,
	BLESSING,
	BUFF,
	LEAD_PLACEMENT,
	RESPONSE_PLACEMENT,
	COMBAT,
	DOMINANT_REVEAL,
	ROUND_END
}

@export var turn_order_state: MatchTurnOrderState
@export var deck_system_root: DeckSystemRoot

@export var start_on_ready: bool = true
@export var enable_debug_keys: bool = true
@export var advance_debug_key: Key = KEY_M
@export var swap_control_debug_key: Key = KEY_TAB

var current_state: MatchState = MatchState.NONE
var current_round: int = 0
var is_running: bool = false
var has_built_starting_hands: bool = false
var transition_lock_count: int = 0

var state_name_helper: MatchStateNameHelper = MatchStateNameHelper.new()
var state_advance_helper: MatchStateAdvanceHelper = MatchStateAdvanceHelper.new()
var active_owner_helper: MatchActiveOwnerResolverHelper = MatchActiveOwnerResolverHelper.new()


func _ready() -> void:
	if turn_order_state != null:
		turn_order_state.setup_for_match()

	if start_on_ready:
		start_match()


func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == advance_debug_key:
		advance_debug_state()

	if key_event.keycode == swap_control_debug_key:
		swap_controlled_owner()


func start_match() -> void:
	if is_running:
		return

	is_running = true
	current_round = 1
	has_built_starting_hands = false
	transition_lock_count = 0

	if turn_order_state != null:
		turn_order_state.setup_for_round(current_round)

	round_changed.emit(current_round)
	set_state(MatchState.ROUND_INTRO)
	_build_starting_hands_once()


func set_state(new_state: MatchState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	apply_active_owner_for_current_state()

	_print_current_state()
	match_state_changed.emit(current_state)


func advance_debug_state() -> void:
	if is_transition_locked():
		print("MATCH ADVANCE BLOCKED: transition locked")
		return

	if state_advance_helper.should_advance_round(current_state):
		advance_round()
		return

	if current_state == MatchState.NONE:
		start_match()
		return

	var next_state: MatchState = state_advance_helper.get_next_state(
		current_state,
		current_round
	)

	set_state(next_state)


func advance_round() -> void:
	if is_transition_locked():
		print("ROUND ADVANCE BLOCKED: transition locked")
		return

	current_round += 1

	if turn_order_state != null:
		turn_order_state.setup_for_round(current_round)

	round_changed.emit(current_round)
	set_state(MatchState.ROUND_INTRO)


func lock_transition() -> void:
	transition_lock_count += 1


func unlock_transition() -> void:
	transition_lock_count = max(transition_lock_count - 1, 0)


func is_transition_locked() -> bool:
	return transition_lock_count > 0


func swap_controlled_owner() -> void:
	if turn_order_state == null:
		return

	turn_order_state.swap_controlled_owner()

	print(
		"CONTROLLED OWNER: ",
		get_controlled_owner_name()
	)


func get_state_name(state: MatchState) -> String:
	return state_name_helper.get_state_name(state)


func get_active_owner_name() -> String:
	if turn_order_state == null:
		return "NONE"

	return turn_order_state.get_owner_name(turn_order_state.active_owner)


func get_controlled_owner_name() -> String:
	if turn_order_state == null:
		return "NONE"

	return turn_order_state.get_owner_name(turn_order_state.controlled_owner)


func apply_active_owner_for_current_state() -> void:
	active_owner_helper.apply_active_owner_for_state(
		current_state,
		turn_order_state
	)


func _build_starting_hands_once() -> void:
	if has_built_starting_hands:
		return

	has_built_starting_hands = true

	if deck_system_root == null:
		print("starting hand skipped: deck_system_root missing")
		return

	deck_system_root.build_match_decks()


func _print_current_state() -> void:
	print(
		"MATCH STATE: ",
		get_state_name(current_state),
		" | ACTIVE: ",
		get_active_owner_name(),
		" | CONTROLLED: ",
		get_controlled_owner_name()
	)
