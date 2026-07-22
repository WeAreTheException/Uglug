extends Control
class_name MatchUiRoot

signal end_turn_pressed
signal worker_draw_pressed
signal warrior_draw_pressed

signal mutation_drop_requested(
	card: CardRoot,
	mutation: Mutation
)

enum Phase {
	NONE,
	DRAW,
	BUFF,
	PLAY,
	WAIT,
	ATTACK,
}

@export_group("Mode")
@export var use_local_test_mode: bool = true

@export_group("Labels")
@export var round_label: Label
@export var going_first_label: Label
@export var phase_label: Label
@export var helper_label: RichTextLabel
@export var timer_label: Label

@export_group("Buttons")
@export var worker_button: Button
@export var warrior_button: Button
@export var buff_button: Button
@export var timer_end_turn_button: Button
@export var undo_button: Button

@export_group("Mutation")
@export var mutation_database: BuffDatabase
@export var player_hand: PlayerHandRoot

@export_group("Button Text")
@export var worker_text: String = "Worker"
@export var warrior_text: String = "Warrior"
@export var arrow_text: String = "↑"
@export var warrior_arrow_text: String = "→"
@export var buff_text: String = "Buff"
@export var empty_text: String = "X"

@export_group("Button Colors")
@export var active_button_color: Color = Color.WHITE

@export var inactive_button_color: Color = Color(
	1.0,
	1.0,
	1.0,
	0.25
)

@export var hidden_button_color: Color = Color(
	1.0,
	1.0,
	1.0,
	0.0
)

@export_group("Helper Styling")
@export var draw_number_color: Color = Color.YELLOW

@export var revealed_card_name_color: Color = Color(
	0.0,
	1.0,
	1.0,
	1.0
)

@export var completed_line_alpha: float = 0.35

var current_phase: Phase = Phase.NONE
var round_number: int = 1

var draw_selected_count: int = 0
var draw_log_entries: Array[Dictionary] = []
var is_draw_reveal_time: bool = false

var buff_start_position: Vector2 = Vector2.ZERO
var has_buff_start_position: bool = false
var is_dragging_buff: bool = false

var active_mutation: Mutation = null
var evolution_request_pending: bool = false


func _ready() -> void:
	_connect_buttons()
	_update_round_label()
	clear_timer()

	_capture_buff_start_position()

	if use_local_test_mode:
		_set_phase(Phase.DRAW)
	else:
		_set_phase(Phase.NONE)


func _process(_delta: float) -> void:
	if not is_dragging_buff:
		return

	if buff_button == null:
		return

	buff_button.global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if not use_local_test_mode:
		return

	if event is not InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_R:
			set_round_number(round_number + 1)

		KEY_D:
			_set_phase(Phase.DRAW)

		KEY_B:
			_set_phase(Phase.BUFF)
			_cycle_mutation()

		KEY_P:
			_set_phase(Phase.PLAY)

		KEY_W:
			_set_phase(Phase.WAIT)

		KEY_A:
			_set_phase(Phase.ATTACK)


func _capture_buff_start_position() -> void:
	await get_tree().process_frame

	if buff_button == null:
		return

	buff_start_position = buff_button.position
	has_buff_start_position = true


func _restore_buff_button_position() -> void:
	if buff_button == null:
		return

	if not has_buff_start_position:
		return

	buff_button.position = buff_start_position


func _connect_buttons() -> void:
	if worker_button != null:
		if not worker_button.pressed.is_connected(
			_on_worker_pressed
		):
			worker_button.pressed.connect(
				_on_worker_pressed
			)

	if warrior_button != null:
		if not warrior_button.pressed.is_connected(
			_on_warrior_pressed
		):
			warrior_button.pressed.connect(
				_on_warrior_pressed
			)

	if buff_button != null:
		if not buff_button.button_down.is_connected(
			_on_buff_button_down
		):
			buff_button.button_down.connect(
				_on_buff_button_down
			)

		if not buff_button.button_up.is_connected(
			_on_buff_button_up
		):
			buff_button.button_up.connect(
				_on_buff_button_up
			)

	if timer_end_turn_button != null:
		if not timer_end_turn_button.pressed.is_connected(
			_on_timer_end_turn_pressed
		):
			timer_end_turn_button.pressed.connect(
				_on_timer_end_turn_pressed
			)


func set_player_hand(hand: PlayerHandRoot) -> void:
	player_hand = hand


func set_round_number(value: int) -> void:
	round_number = maxi(value, 0)
	_update_round_label()


func set_going_first_text(value: String) -> void:
	if going_first_label == null:
		return

	going_first_label.text = value


func apply_match_state(
	state: MatchFlowRoot.MatchState,
	local_player_is_active: bool = false
) -> void:
	match state:
		MatchFlowRoot.MatchState.AUTO_DRAW:
			_set_phase(Phase.DRAW)

		MatchFlowRoot.MatchState.BUFF:
			_set_phase(Phase.BUFF)

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			if local_player_is_active:
				_set_phase(Phase.PLAY)
			else:
				_set_phase(Phase.WAIT)

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			if local_player_is_active:
				_set_phase(Phase.PLAY)
			else:
				_set_phase(Phase.WAIT)

		MatchFlowRoot.MatchState.COMBAT:
			_set_phase(Phase.ATTACK)

		MatchFlowRoot.MatchState.DOMINANT_REVEAL:
			_set_phase(Phase.ATTACK)
			_set_phase_text("Reveal")

		MatchFlowRoot.MatchState.ROUND_INTRO:
			_set_phase(Phase.NONE)
			_set_phase_text("Round Intro")

		MatchFlowRoot.MatchState.ROUND_END:
			_set_phase(Phase.NONE)
			_set_phase_text("Round End")

		MatchFlowRoot.MatchState.GAME_END:
			_set_phase(Phase.NONE)
			_set_phase_text("Game End")

		MatchFlowRoot.MatchState.BLESSING:
			_set_phase(Phase.NONE)
			_set_phase_text("Blessing")

		_:
			_set_phase(Phase.NONE)


func set_offered_mutation(mutation: Mutation) -> void:
	active_mutation = mutation
	evolution_request_pending = false

	if mutation == null:
		_set_mutation_button_texture(null)

		if current_phase == Phase.BUFF:
			_set_button_state(
				buff_button,
				"",
				false,
				inactive_button_color
			)

		return

	_set_mutation_button_texture(
		mutation.sigil_texture
	)

	if current_phase == Phase.BUFF:
		_set_button_state(
			buff_button,
			"",
			true,
			active_button_color
		)

		_set_helper_text(
			_evolution_helper_text(false)
		)


func get_active_mutation() -> Mutation:
	return active_mutation


func complete_evolution(
	card: CardRoot,
	mutation: Mutation = null
) -> void:
	evolution_request_pending = false
	is_dragging_buff = false

	_restore_buff_button_position()

	if card != null:
		if is_instance_valid(card):
			if player_hand != null:
				if player_hand.has_card(card):
					player_hand.play_evolution_feedback(
						card
					)

	if (
		mutation != null
		and active_mutation != null
	):
		var confirmed_id := (
			mutation.get_safe_mutation_id()
		)

		var active_id := (
			active_mutation.get_safe_mutation_id()
		)

		if confirmed_id != active_id:
			return

	active_mutation = null
	_set_mutation_button_texture(null)

	_set_button_state(
		buff_button,
		"",
		false,
		inactive_button_color
	)

	_set_helper_text(
		"Evolution complete."
	)


func set_timer_seconds(seconds: float) -> void:
	if timer_label == null:
		return

	var shown_seconds: int = maxi(
		int(ceil(seconds)),
		0
	)

	timer_label.text = str(shown_seconds)


func clear_timer() -> void:
	if timer_label == null:
		return

	timer_label.text = "0"


func add_draw_log_entry(
	card_type: String
) -> void:
	if current_phase != Phase.DRAW:
		return

	if draw_selected_count >= 2:
		return

	draw_selected_count += 1

	draw_log_entries.append({
		"type": card_type,
		"revealed_name": ""
	})

	_refresh_draw_helper_text()

	if draw_selected_count >= 2:
		_set_draw_buttons_enabled(false)


func set_draw_log_entry_revealed(
	index: int,
	card_name: String
) -> void:
	if index < 0:
		return

	if index >= draw_log_entries.size():
		return

	var entry: Dictionary = (
		draw_log_entries[index] as Dictionary
	)

	if entry.get("type", "") != "warrior":
		return

	entry["revealed_name"] = card_name
	draw_log_entries[index] = entry

	_refresh_draw_helper_text()


func start_draw_reveal_time() -> void:
	is_draw_reveal_time = true
	_refresh_draw_helper_text()


func clear_draw_log() -> void:
	draw_selected_count = 0
	draw_log_entries.clear()
	is_draw_reveal_time = false

	_refresh_draw_helper_text()
	_set_draw_buttons_enabled(
		use_local_test_mode
	)


func set_draw_buttons_enabled(
	enabled: bool
) -> void:
	_set_draw_buttons_enabled(enabled)


func _set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	is_dragging_buff = false

	_restore_buff_button_position()

	match current_phase:
		Phase.DRAW:
			_enter_draw_phase()

		Phase.BUFF:
			_enter_buff_phase()

		Phase.PLAY:
			_enter_play_phase()

		Phase.WAIT:
			_enter_wait_phase()

		Phase.ATTACK:
			_enter_attack_phase()

		_:
			_enter_none_phase()


func _enter_none_phase() -> void:
	evolution_request_pending = false
	active_mutation = null

	_set_mutation_button_texture(null)
	_set_helper_text("")

	_clear_pile_buttons()
	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _enter_draw_phase() -> void:
	draw_selected_count = 0
	draw_log_entries.clear()
	is_draw_reveal_time = false

	evolution_request_pending = false
	active_mutation = null

	_set_phase_text("Draw")
	_refresh_draw_helper_text()
	_set_mutation_button_texture(null)

	_set_button_state(
		worker_button,
		worker_text,
		use_local_test_mode,
		active_button_color
	)

	_set_button_state(
		warrior_button,
		warrior_text,
		use_local_test_mode,
		active_button_color
	)

	_set_button_state(
		buff_button,
		empty_text,
		false,
		inactive_button_color
	)

	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _enter_buff_phase() -> void:
	evolution_request_pending = false

	_set_phase_text("Evolution")

	_set_helper_text(
		_evolution_helper_text(false)
	)

	_set_button_state(
		worker_button,
		arrow_text,
		false,
		inactive_button_color
	)

	_set_button_state(
		warrior_button,
		warrior_arrow_text,
		false,
		inactive_button_color
	)

	var has_mutation := active_mutation != null

	_set_button_state(
		buff_button,
		"",
		has_mutation,
		active_button_color
	)

	if active_mutation != null:
		_set_mutation_button_texture(
			active_mutation.sigil_texture
		)
	else:
		_set_mutation_button_texture(null)

	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _enter_play_phase() -> void:
	_set_phase_text("Play")

	_set_helper_text(
		"Select Card\nChoose x martyrs\nPlace"
	)

	_clear_pile_buttons()
	_set_end_turn_enabled(true)
	_set_undo_visible(false)


func _enter_wait_phase() -> void:
	_set_phase_text("Wait")

	_set_helper_text(
		"Enemy is placing cards right now."
	)

	_clear_pile_buttons()
	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _enter_attack_phase() -> void:
	_set_phase_text("Attack")
	_set_helper_text("")

	_clear_pile_buttons()
	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _on_worker_pressed() -> void:
	if current_phase != Phase.DRAW:
		return

	if draw_selected_count >= 2:
		return

	if use_local_test_mode:
		add_draw_log_entry("worker")

	worker_draw_pressed.emit()


func _on_warrior_pressed() -> void:
	if current_phase != Phase.DRAW:
		return

	if draw_selected_count >= 2:
		return

	if use_local_test_mode:
		add_draw_log_entry("warrior")

	warrior_draw_pressed.emit()


func _cycle_mutation() -> void:
	if not use_local_test_mode:
		return

	if mutation_database == null:
		set_offered_mutation(null)
		return

	var mutations: Array[Mutation] = (
		mutation_database.get_available_mutations()
	)

	if (
		mutations.size() > 1
		and active_mutation != null
	):
		mutations.erase(active_mutation)

	if mutations.is_empty():
		set_offered_mutation(null)
		return

	set_offered_mutation(
		mutations.pick_random() as Mutation
	)


func _set_mutation_button_texture(
	texture: Texture2D
) -> void:
	if buff_button == null:
		return

	buff_button.text = ""
	buff_button.icon = texture
	buff_button.expand_icon = true

	buff_button.icon_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)


func _on_buff_button_down() -> void:
	if current_phase != Phase.BUFF:
		return

	if active_mutation == null:
		return

	if evolution_request_pending:
		return

	is_dragging_buff = true

	_set_helper_text(
		_evolution_helper_text(true)
	)


func _on_buff_button_up() -> void:
	if current_phase != Phase.BUFF:
		return

	if evolution_request_pending:
		return

	is_dragging_buff = false

	var target_card := (
		_get_mutation_drop_target()
	)

	_restore_buff_button_position()

	if not _is_valid_mutation_target(target_card):
		_set_helper_text(
			_evolution_helper_text(false)
		)
		return

	if use_local_test_mode:
		var applied := target_card.add_buff_mutation(
			active_mutation
		)

		if not applied:
			_set_helper_text(
				_evolution_helper_text(false)
			)
			return

		complete_evolution(
			target_card,
			active_mutation
		)
		return

	evolution_request_pending = true

	_set_button_state(
		buff_button,
		"",
		false,
		inactive_button_color
	)

	_set_helper_text(
		"Waiting for confirmation."
	)

	mutation_drop_requested.emit(
		target_card,
		active_mutation
	)


func _get_mutation_drop_target() -> CardRoot:
	if player_hand == null:
		return null

	if player_hand.interaction_root == null:
		return null

	player_hand.interaction_root.refresh_hover_focus()

	return (
		player_hand
		.interaction_root
		.get_top_hovered_card()
	)


func _is_valid_mutation_target(
	card: CardRoot
) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	if active_mutation == null:
		return false

	if player_hand == null:
		return false

	if not player_hand.has_card(card):
		return false

	return card.can_receive_buff_mutation(
		active_mutation
	)


func _on_timer_end_turn_pressed() -> void:
	if current_phase != Phase.PLAY:
		return

	end_turn_pressed.emit()


func _set_draw_buttons_enabled(
	enabled: bool
) -> void:
	_set_button_enabled(
		worker_button,
		enabled
	)

	_set_button_enabled(
		warrior_button,
		enabled
	)


func _refresh_draw_helper_text() -> void:
	var cards_left: int = maxi(
		2 - draw_selected_count,
		0
	)

	var lines: Array[String] = []

	if not is_draw_reveal_time:
		var header_text := (
			_draw_header_text(cards_left)
		)

		if header_text != "":
			lines.append(header_text)

	for raw_entry in draw_log_entries:
		var entry := raw_entry as Dictionary

		lines.append(
			_draw_entry_text(entry)
		)

	_set_helper_text(
		"\n".join(lines)
	)


func _draw_header_text(
	cards_left: int
) -> String:
	if cards_left <= 0:
		return ""

	return "Draw [color=%s]%s[/color] card%s" % [
		draw_number_color.to_html(false),
		cards_left,
		"" if cards_left == 1 else "s"
	]


func _draw_entry_text(
	entry: Dictionary
) -> String:
	var card_type: String = entry.get(
		"type",
		""
	)

	var revealed_name: String = entry.get(
		"revealed_name",
		""
	)

	if (
		card_type == "warrior"
		and revealed_name != ""
	):
		return "Drew [color=%s]%s[/color]" % [
			revealed_card_name_color.to_html(
				false
			),
			revealed_name
		]

	return "Drew %s" % card_type


func _evolution_helper_text(
	is_selecting_mutation_done: bool
) -> String:
	if is_selecting_mutation_done:
		return (
			"[color=#ffffff59]"
			+ "Select mutation."
			+ "[/color]\n"
			+ "Drag onto an ant."
		)

	return "Select mutation.\nDrag onto an ant."


func _set_phase_text(text: String) -> void:
	if phase_label == null:
		return

	phase_label.text = text


func _set_helper_text(text: String) -> void:
	if helper_label == null:
		return

	helper_label.bbcode_enabled = true
	helper_label.text = text


func _update_round_label() -> void:
	if round_label == null:
		return

	round_label.text = (
		"Round %s" % round_number
	)


func _set_button_state(
	button: Button,
	text: String,
	enabled: bool,
	color: Color
) -> void:
	if button == null:
		return

	button.text = text
	button.disabled = not enabled
	button.visible = true
	button.modulate = color


func _set_button_enabled(
	button: Button,
	enabled: bool
) -> void:
	if button == null:
		return

	button.disabled = not enabled

	button.modulate = (
		active_button_color
		if enabled
		else inactive_button_color
	)


func _clear_pile_buttons() -> void:
	active_mutation = null
	_set_mutation_button_texture(null)

	_set_button_state(
		worker_button,
		"",
		false,
		hidden_button_color
	)

	_set_button_state(
		warrior_button,
		"",
		false,
		hidden_button_color
	)

	_set_button_state(
		buff_button,
		"",
		false,
		hidden_button_color
	)


func _set_end_turn_enabled(
	enabled: bool
) -> void:
	if timer_end_turn_button == null:
		return

	timer_end_turn_button.disabled = not enabled

	if enabled:
		timer_end_turn_button.text = "End Turn"

		timer_end_turn_button.modulate = (
			active_button_color
		)
	else:
		timer_end_turn_button.text = ""

		timer_end_turn_button.modulate = (
			inactive_button_color
		)


func _set_undo_visible(
	is_visible: bool
) -> void:
	if undo_button == null:
		return

	undo_button.visible = is_visible
