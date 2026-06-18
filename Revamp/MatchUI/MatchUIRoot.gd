extends Control
class_name MatchUIRoot

@export var match_flow_root: MatchFlowRoot
@export var slots_root: SlotsRoot
@export var score_state: MatchScoreState
@export var phase_timer: MatchPhaseTimer
@export var placement_completion_handler: MatchPlacementCompletionHandler

@export var tugga_display: TuggaBattleScaleDisplay
@export var attack_order_arrow_display: AttackOrderArrowDisplay
@export var end_turn_button: BaseButton

@export var host_name_label: Label
@export var client_name_label: Label

@export var phase_title_label: Label
@export var phase_timer_label: Label
@export var initiator_name_label: Label

@export var name_outline_size: int = 4
@export var print_name_debug: bool = false
@export var print_phase_debug: bool = false


func _ready() -> void:
	_resolve_score_state()
	_setup_children()
	_setup_name_labels()
	_connect_match_flow()
	_connect_phase_timer()
	_setup_end_turn_button()
	_refresh_phase_labels()
	call_deferred("_setup_name_labels")
	call_deferred("_setup_end_turn_button")
	call_deferred("_refresh_phase_labels")

func setup_match_context(
	source_match_flow_root: MatchFlowRoot,
	source_slots_root: SlotsRoot
) -> void:
	match_flow_root = source_match_flow_root
	slots_root = source_slots_root

	_resolve_score_state()
	_setup_children()
	_setup_name_labels()
	_connect_match_flow()
	_refresh_phase_labels()


func setup_phase_timer(source_phase_timer: MatchPhaseTimer) -> void:
	phase_timer = source_phase_timer
	_connect_phase_timer()


func _resolve_score_state() -> void:
	if score_state != null:
		return

	if match_flow_root == null:
		return

	score_state = match_flow_root.score_state


func _setup_children() -> void:
	if tugga_display != null:
		tugga_display.setup(score_state)

	if attack_order_arrow_display != null:
		attack_order_arrow_display.setup(
			slots_root,
			_get_turn_order_state()
		)


func _connect_match_flow() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)

	if not match_flow_root.round_changed.is_connected(_on_round_changed):
		match_flow_root.round_changed.connect(_on_round_changed)


func _connect_phase_timer() -> void:
	if phase_timer == null:
		return

	if not phase_timer.timer_started.is_connected(_on_phase_timer_started):
		phase_timer.timer_started.connect(_on_phase_timer_started)

	if not phase_timer.timer_ticked.is_connected(_on_phase_timer_ticked):
		phase_timer.timer_ticked.connect(_on_phase_timer_ticked)

	if not phase_timer.timer_finished.is_connected(_on_phase_timer_finished):
		phase_timer.timer_finished.connect(_on_phase_timer_finished)


func _on_match_state_changed(_state: MatchFlowRoot.MatchState) -> void:
	_refresh_phase_labels()


func _on_round_changed(_round_number: int) -> void:
	_refresh_phase_labels()


func _on_phase_timer_started(
	_state: MatchFlowRoot.MatchState,
	duration: float
) -> void:
	_update_phase_timer_text(duration)


func _on_phase_timer_ticked(
	_state: MatchFlowRoot.MatchState,
	remaining: float
) -> void:
	_update_phase_timer_text(remaining)


func _on_phase_timer_finished(_state: MatchFlowRoot.MatchState) -> void:
	_update_phase_timer_text(0.0)


func _refresh_phase_labels() -> void:
	_update_phase_title()
	_update_initiator_name()

	if print_phase_debug:
		print(
			"MATCH UI PHASE REFRESH | phase=",
			_get_phase_title_text(),
			" initiator=",
			_get_initiator_text()
		)


func _update_phase_title() -> void:
	if phase_title_label == null:
		return

	phase_title_label.text = _get_phase_title_text()


func _update_phase_timer_text(seconds: float) -> void:
	if phase_timer_label == null:
		return

	var total_seconds: int = max(int(ceil(seconds)), 0)
	var minutes: int = total_seconds / 60
	var remainder: int = total_seconds % 60

	phase_timer_label.text = "%d:%02d" % [minutes, remainder]


func _update_initiator_name() -> void:
	if initiator_name_label == null:
		return

	initiator_name_label.text = _get_initiator_text()


func _get_phase_title_text() -> String:
	if match_flow_root == null:
		return "PHASE"

	match match_flow_root.current_state:
		MatchFlowRoot.MatchState.ROUND_INTRO:
			return "ROUND " + str(match_flow_root.current_round)

		MatchFlowRoot.MatchState.AUTO_DRAW:
			return "AUTO DRAW"

		MatchFlowRoot.MatchState.BLESSING:
			return "BLESSING"

		MatchFlowRoot.MatchState.BUFF:
			return "BUFF"

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			return "PLACE"

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			return "PLACE"

		MatchFlowRoot.MatchState.COMBAT:
			return "COMBAT"

		MatchFlowRoot.MatchState.ROUND_END:
			return "ROUND END"

		MatchFlowRoot.MatchState.GAME_END:
			return "GAME END"

	return "PHASE"


func _get_initiator_text() -> String:
	var turn_order_state := _get_turn_order_state()

	if turn_order_state == null:
		return ""

	var owner_name := turn_order_state.get_owner_name(
		turn_order_state.attacking_first_owner
	)

	return owner_name + " attacks first"


func _setup_name_labels() -> void:
	_apply_name_label_style(host_name_label)
	_apply_name_label_style(client_name_label)

	var local_client_id: int = _get_local_client_id()
	var other_client_id: int = _get_other_client_id(local_client_id)

	var host_client_id: int = local_client_id
	var client_client_id: int = other_client_id

	if not GDSync.is_host():
		host_client_id = other_client_id
		client_client_id = local_client_id

	var host_name: String = _get_client_display_name(host_client_id, "Host")
	var client_name: String = _get_client_display_name(client_client_id, "Client")

	if host_name_label != null:
		host_name_label.text = host_name

	if client_name_label != null:
		client_name_label.text = client_name

	if print_name_debug:
		print("MATCH UI LOCAL ID: ", local_client_id)
		print("MATCH UI OTHER ID: ", other_client_id)
		print("MATCH UI HOST ID: ", host_client_id, " NAME: ", host_name)
		print("MATCH UI CLIENT ID: ", client_client_id, " NAME: ", client_name)


func _apply_name_label_style(label: Label) -> void:
	if label == null:
		return

	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", name_outline_size)


func _get_local_client_id() -> int:
	var raw_id := str(GDSync.get_client_id())

	if raw_id.is_valid_int():
		return raw_id.to_int()

	return abs(raw_id.hash())


func _get_other_client_id(local_client_id: int) -> int:
	var clients: Array = GDSync.lobby_get_all_clients()

	for client in clients:
		var client_id: int = _client_to_int(client)

		if client_id != local_client_id:
			return client_id

	return -1


func _client_to_int(client) -> int:
	var raw_id := str(client)

	if raw_id.is_valid_int():
		return raw_id.to_int()

	return abs(raw_id.hash())


func _get_client_display_name(client_id: int, fallback_label: String) -> String:
	if client_id < 0:
		return fallback_label

	var fallback_name := PlaceholderPlayerNames.get_name_for_id(client_id)

	return GDSync.player_get_username(client_id, fallback_name)


func _get_turn_order_state() -> MatchTurnOrderState:
	if match_flow_root == null:
		return null

	return match_flow_root.turn_order_state


func _setup_end_turn_button() -> void:
	if placement_completion_handler == null:
		print("MATCH UI END TURN SETUP FAILED: placement_completion_handler missing")
		return

	if end_turn_button == null:
		print("MATCH UI END TURN SETUP FAILED: end_turn_button missing")
		return

	placement_completion_handler.setup_end_turn_button(end_turn_button)
