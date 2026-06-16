extends Node
class_name MatchFlowRoot

signal match_state_changed(state: MatchState)
signal round_changed(round_number: int)
signal match_ended(winner: SlotRow.SlotOwner, final_score: int)

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
	ROUND_END,
	GAME_END
}

@export var turn_order_state: MatchTurnOrderState
@export var deck_system_root: DeckSystemRoot
@export var score_state: MatchScoreState

@export var start_on_ready: bool = true
@export var enable_debug_keys: bool = true
@export var advance_debug_key: Key = KEY_M
@export var swap_control_debug_key: Key = KEY_TAB
@export var print_debug: bool = true

var current_state: MatchState = MatchState.NONE
var current_round: int = 0
var is_running: bool = false
var has_built_starting_hands: bool = false
var transition_lock_count: int = 0

var has_match_winner: bool = false
var match_winner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var final_score: int = 0

var state_name_helper: MatchStateNameHelper = MatchStateNameHelper.new()
var state_advance_helper: MatchStateAdvanceHelper = MatchStateAdvanceHelper.new()
var active_owner_helper: MatchActiveOwnerResolverHelper = MatchActiveOwnerResolverHelper.new()


func _ready() -> void:
	if turn_order_state != null:
		turn_order_state.setup_for_match()

	_connect_score_state()

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
	has_match_winner = false
	final_score = 0

	if score_state != null:
		score_state.reset_score()

	if turn_order_state != null:
		turn_order_state.setup_for_round(current_round)

	round_changed.emit(current_round)
	set_state(MatchState.ROUND_INTRO)
	_build_starting_hands_once()


func set_state(new_state: MatchState) -> void:
	if current_state == new_state:
		return

	if current_state == MatchState.GAME_END:
		return

	current_state = new_state
	apply_active_owner_for_current_state()

	_print_current_state()
	match_state_changed.emit(current_state)


func end_match(
	winner: SlotRow.SlotOwner,
	score: int
) -> void:
	if has_match_winner:
		return

	has_match_winner = true
	match_winner = winner
	final_score = score
	is_running = false
	transition_lock_count = 0

	current_state = MatchState.GAME_END
	apply_active_owner_for_current_state()

	if print_debug:
		print(
			"MATCH ENDED | WINNER: ",
			_get_owner_name(match_winner),
			" | SCORE: ",
			final_score
		)

	match_state_changed.emit(current_state)
	match_ended.emit(match_winner, final_score)


func advance_debug_state() -> void:
	host_advance_match_state()


func advance_round() -> void:
	if current_state == MatchState.GAME_END:
		return

	if is_transition_locked():
		if print_debug:
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

	if print_debug:
		print("CONTROLLED OWNER: ", get_controlled_owner_name())


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


func _connect_score_state() -> void:
	if score_state == null:
		return

	if not score_state.threshold_reached.is_connected(_on_score_threshold_reached):
		score_state.threshold_reached.connect(_on_score_threshold_reached)


func _on_score_threshold_reached(
	winner: SlotRow.SlotOwner,
	score: int
) -> void:
	end_match(winner, score)


func _build_starting_hands_once() -> void:
	if has_built_starting_hands:
		return

	has_built_starting_hands = true

	if deck_system_root == null:
		if print_debug:
			print("starting hand skipped: deck_system_root missing")
		return

	if not GDSync.is_host():
		if print_debug:
			print("starting hand skipped: waiting for host setup payload")
		return

	deck_system_root.build_match_decks()


func _print_current_state() -> void:
	if not print_debug:
		return

	print(
		"MATCH STATE: ",
		get_state_name(current_state),
		" | ACTIVE: ",
		get_active_owner_name(),
		" | CONTROLLED: ",
		get_controlled_owner_name()
	)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if turn_order_state != null:
		return turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"

func host_advance_match_state() -> bool:
	if not GDSync.is_host():
		return false

	if current_state == MatchState.GAME_END:
		if print_debug:
			print("MATCH ADVANCE BLOCKED: game ended")
		return false

	if is_transition_locked():
		if print_debug:
			print("MATCH ADVANCE BLOCKED: transition locked")
		return false

	if state_advance_helper.should_advance_round(current_state):
		advance_round()
		return true

	if current_state == MatchState.NONE:
		start_match()
		return true

	var next_state := state_advance_helper.get_next_state(
		current_state,
		current_round
	)

	set_state(next_state)
	return true

func get_network_snapshot() -> Dictionary:
	var payload := {
		"state": int(current_state),
		"round": current_round,
		"transition_lock_count": transition_lock_count,
		"has_match_winner": has_match_winner,
		"winner": int(match_winner),
		"final_score": final_score,
		"active_owner": int(SlotRow.SlotOwner.PLAYER),
		"attacking_first_owner": int(SlotRow.SlotOwner.PLAYER),
		"lead_placement_owner": int(SlotRow.SlotOwner.PLAYER),
		"response_placement_owner": int(SlotRow.SlotOwner.OPPONENT),
	}

	if turn_order_state != null:
		payload["active_owner"] = int(turn_order_state.active_owner)
		payload["attacking_first_owner"] = int(turn_order_state.attacking_first_owner)
		payload["lead_placement_owner"] = int(turn_order_state.lead_placement_owner)
		payload["response_placement_owner"] = int(turn_order_state.response_placement_owner)

	return payload


func apply_network_snapshot(payload: Dictionary) -> void:
	var old_state := current_state
	var old_round := current_round

	current_round = int(payload.get("round", current_round))
	transition_lock_count = int(payload.get("transition_lock_count", 0))
	has_match_winner = bool(payload.get("has_match_winner", false))
	final_score = int(payload.get("final_score", final_score))
	match_winner = int(payload.get("winner", match_winner)) as SlotRow.SlotOwner

	if turn_order_state != null:
		turn_order_state.apply_network_owners(
			int(payload.get("active_owner", turn_order_state.active_owner)) as SlotRow.SlotOwner,
			int(payload.get("attacking_first_owner", turn_order_state.attacking_first_owner)) as SlotRow.SlotOwner,
			int(payload.get("lead_placement_owner", turn_order_state.lead_placement_owner)) as SlotRow.SlotOwner,
			int(payload.get("response_placement_owner", turn_order_state.response_placement_owner)) as SlotRow.SlotOwner
		)

	current_state = int(payload.get("state", current_state)) as MatchState
	is_running = current_state != MatchState.NONE and current_state != MatchState.GAME_END

	if old_round != current_round:
		round_changed.emit(current_round)

	if old_state != current_state:
		_print_current_state()
		match_state_changed.emit(current_state)
