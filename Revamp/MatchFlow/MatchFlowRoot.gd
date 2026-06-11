extends Node
class_name MatchFlowRoot

signal match_state_changed(state: MatchState)
signal round_changed(round_number: int)

enum MatchState {
	NONE,
	ROUND_INTRO,
	AUTO_DRAW,
	REVENANT,
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


func _ready() -> void:
	if turn_order_state != null:
		turn_order_state.setup_for_match()

	if start_on_ready:
		start_match()


func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == advance_debug_key:
			advance_debug_state()

		if event.keycode == swap_control_debug_key:
			swap_controlled_owner()


func start_match() -> void:
	if is_running:
		return

	is_running = true
	current_round = 1
	has_built_starting_hands = false

	if turn_order_state != null:
		turn_order_state.setup_for_round(current_round)

	round_changed.emit(current_round)
	set_state(MatchState.ROUND_INTRO)
	_build_starting_hands_once()


func set_state(new_state: MatchState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	_apply_active_owner_for_state(current_state)

	match_state_changed.emit(current_state)

	print(
		"MATCH STATE: ",
		get_state_name(current_state),
		" | ACTIVE: ",
		get_active_owner_name(),
		" | CONTROLLED: ",
		get_controlled_owner_name()
	)


func advance_debug_state() -> void:
	match current_state:
		MatchState.NONE:
			start_match()

		MatchState.ROUND_INTRO:
			if current_round == 1:
				set_state(MatchState.REVENANT)
			else:
				set_state(MatchState.AUTO_DRAW)

		MatchState.AUTO_DRAW:
			set_state(MatchState.BUFF)

		MatchState.REVENANT:
			set_state(MatchState.LEAD_PLACEMENT)

		MatchState.BUFF:
			set_state(MatchState.LEAD_PLACEMENT)

		MatchState.LEAD_PLACEMENT:
			set_state(MatchState.RESPONSE_PLACEMENT)

		MatchState.RESPONSE_PLACEMENT:
			set_state(MatchState.COMBAT)

		MatchState.COMBAT:
			if current_round == 1:
				set_state(MatchState.DOMINANT_REVEAL)
			else:
				set_state(MatchState.ROUND_END)

		MatchState.DOMINANT_REVEAL:
			set_state(MatchState.ROUND_END)

		MatchState.ROUND_END:
			advance_round()


func advance_round() -> void:
	current_round += 1

	if turn_order_state != null:
		turn_order_state.setup_for_round(current_round)

	round_changed.emit(current_round)
	set_state(MatchState.ROUND_INTRO)


func swap_controlled_owner() -> void:
	if turn_order_state == null:
		return

	turn_order_state.swap_controlled_owner()

	print(
		"CONTROLLED OWNER: ",
		get_controlled_owner_name()
	)


func get_state_name(state: MatchState) -> String:
	match state:
		MatchState.NONE:
			return "NONE"
		MatchState.ROUND_INTRO:
			return "ROUND_INTRO"
		MatchState.AUTO_DRAW:
			return "AUTO_DRAW"
		MatchState.REVENANT:
			return "REVENANT"
		MatchState.BUFF:
			return "BUFF"
		MatchState.LEAD_PLACEMENT:
			return "LEAD_PLACEMENT"
		MatchState.RESPONSE_PLACEMENT:
			return "RESPONSE_PLACEMENT"
		MatchState.COMBAT:
			return "COMBAT"
		MatchState.DOMINANT_REVEAL:
			return "DOMINANT_REVEAL"
		MatchState.ROUND_END:
			return "ROUND_END"

	return "UNKNOWN"


func get_active_owner_name() -> String:
	if turn_order_state == null:
		return "NONE"

	return turn_order_state.get_owner_name(turn_order_state.active_owner)


func get_controlled_owner_name() -> String:
	if turn_order_state == null:
		return "NONE"

	return turn_order_state.get_owner_name(turn_order_state.controlled_owner)


func _build_starting_hands_once() -> void:
	if has_built_starting_hands:
		return

	has_built_starting_hands = true

	if deck_system_root == null:
		print("starting hand skipped: deck_system_root missing")
		return

	deck_system_root.build_match_decks()


func _apply_active_owner_for_state(state: MatchState) -> void:
	if turn_order_state == null:
		return

	match state:
		MatchState.LEAD_PLACEMENT:
			turn_order_state.set_active_owner(
				turn_order_state.lead_placement_owner
			)

		MatchState.RESPONSE_PLACEMENT:
			turn_order_state.set_active_owner(
				turn_order_state.response_placement_owner
			)

		MatchState.COMBAT:
			turn_order_state.set_active_owner(
				turn_order_state.attacking_first_owner
			)

		_:
			turn_order_state.set_active_owner(
				turn_order_state.attacking_first_owner
			)
