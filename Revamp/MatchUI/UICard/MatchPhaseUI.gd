extends Control
class_name MatchPhaseUI


signal end_turn_pressed
signal phase_changed(new_phase: Phase)


enum Phase {
	NONE,
	ROUND_INTRO,
	DRAW,
	AUTO_DRAW,
	EVOLUTION,
	PLAY,
	WAIT,
	ATTACK,
	ROUND_END,
	GAME_END
}


@export_group("Labels")
@export var phase_label: Label
@export var going_first_label: Label
@export var description_label: RichTextLabel
@export var timer_label: Label
@export var round_number_label: Label

@export_group("Buttons")
@export var end_button: Button
@export var mutation_button: Button
@export var worker_button: Button
@export var warrior_button: Button

@export_group("End Button")
@export var hide_end_button_outside_play: bool = true

@export_group("Mutation Button")
@export_range(0.0, 1.0, 0.05)
var mutation_normal_opacity: float = 1.0

@export_range(0.0, 1.0, 0.05)
var mutation_selected_opacity: float = 0.45

@export_group("Phase Shadow Colors")
@export var draw_shadow_color: Color = Color(
	0.2,
	0.65,
	1.0,
	1.0
)

@export var evolution_shadow_color: Color = Color(
	1.0,
	0.25,
	0.25,
	1.0
)

@export var play_wait_shadow_color: Color = Color(
	0.25,
	0.9,
	0.35,
	1.0
)

@export var attack_shadow_color: Color = Color(
	1.0,
	0.85,
	0.2,
	1.0
)

@export var other_phase_shadow_color: Color = Color(
	0.7,
	0.4,
	1.0,
	1.0
)


var current_phase: Phase = Phase.NONE
var round_number: int = 1

var local_player_is_going_first: bool = false
var has_going_first_value: bool = false

var end_button_locked: bool = false
var mutation_is_selected: bool = false

var draw_entries: Array[String] = []
var draw_is_complete: bool = false

var selected_card_martyr_cost: int = 0
var game_result_text: String = "Game complete"
var evolution_result_text: String = ""

var default_phase_text: String = ""
var default_going_first_text: String = ""
var default_description_text: String = ""

var default_phase_shadow_color: Color = Color.WHITE
var default_going_first_shadow_color: Color = Color.WHITE


func _ready() -> void:
	_prepare_label_settings(phase_label)
	_prepare_label_settings(going_first_label)
	_store_inspector_defaults()

	if end_button != null:
		if not end_button.pressed.is_connected(
			_on_end_button_pressed
		):
			end_button.pressed.connect(
				_on_end_button_pressed
			)

	_set_mutation_opacity(mutation_normal_opacity)
	_apply_all_ui()


func set_phase(new_phase: Phase) -> void:
	if current_phase == new_phase:
		return

	current_phase = new_phase

	_on_phase_entered(new_phase)
	_apply_all_ui()

	phase_changed.emit(current_phase)


func set_round_number(new_round_number: int) -> void:
	round_number = maxi(new_round_number, 1)

	_update_round_number_label()

	if current_phase == Phase.ROUND_INTRO:
		_update_description()


func set_local_player_going_first(
	is_going_first: bool
) -> void:
	local_player_is_going_first = is_going_first
	has_going_first_value = true

	_update_going_first_label()


func clear_going_first_value() -> void:
	has_going_first_value = false
	_update_going_first_label()


func set_time_remaining(
	seconds_remaining: float
) -> void:
	if timer_label == null:
		return

	var total_seconds: int = maxi(
		ceili(seconds_remaining),
		0
	)

	var minutes: int = floori(
		float(total_seconds) / 60.0
	)

	var seconds: int = total_seconds % 60

	timer_label.text = "%d:%02d" % [
		minutes,
		seconds
	]


func set_timer_visible(is_visible: bool) -> void:
	if timer_label != null:
		timer_label.visible = is_visible


func set_end_button_locked(is_locked: bool) -> void:
	end_button_locked = is_locked
	_update_end_button()


func set_placement_martyr_cost(
	martyr_cost: int
) -> void:
	selected_card_martyr_cost = maxi(
		martyr_cost,
		0
	)

	if current_phase == Phase.PLAY:
		_update_description()


func reset_draw_status() -> void:
	draw_entries.clear()
	draw_is_complete = false

	if (
		current_phase == Phase.DRAW
		or current_phase == Phase.AUTO_DRAW
	):
		_update_description()


func add_draw_result(pile_name: String) -> void:
	var safe_pile_name: String = (
		pile_name
		.strip_edges()
		.to_lower()
	)

	match safe_pile_name:
		"worker":
			draw_entries.append("Drew worker")

		"warrior":
			draw_entries.append("Drew warrior")

		_:
			draw_entries.append(
				"Drew %s" % safe_pile_name
			)

	if (
		current_phase == Phase.DRAW
		or current_phase == Phase.AUTO_DRAW
	):
		_update_description()


func set_draw_complete(
	is_complete: bool = true
) -> void:
	draw_is_complete = is_complete

	if (
		current_phase == Phase.DRAW
		or current_phase == Phase.AUTO_DRAW
	):
		_update_description()


func set_evolution_mutation_selected(
	is_selected: bool
) -> void:
	mutation_is_selected = is_selected

	if mutation_is_selected:
		evolution_result_text = ""

		_set_mutation_opacity(
			mutation_selected_opacity
		)
	else:
		_set_mutation_opacity(
			mutation_normal_opacity
		)

	if current_phase == Phase.EVOLUTION:
		_update_description()


func show_evolved_card(card_name: String) -> void:
	var safe_card_name: String = card_name.strip_edges()

	if safe_card_name.is_empty():
		safe_card_name = "Card"

	mutation_is_selected = false
	evolution_result_text = "\"%s\" evolved" % safe_card_name

	_set_mutation_opacity(
		mutation_normal_opacity
	)

	if current_phase == Phase.EVOLUTION:
		_update_description()


func set_game_result(
	did_local_player_win: bool
) -> void:
	if did_local_player_win:
		game_result_text = "Victory!"
	else:
		game_result_text = "Defeat"

	if current_phase == Phase.GAME_END:
		_update_description()


func set_game_result_text(new_text: String) -> void:
	game_result_text = new_text

	if current_phase == Phase.GAME_END:
		_update_description()


func _on_phase_entered(new_phase: Phase) -> void:
	match new_phase:
		Phase.DRAW:
			draw_entries.clear()
			draw_is_complete = false

		Phase.AUTO_DRAW:
			draw_is_complete = false

		Phase.EVOLUTION:
			mutation_is_selected = false
			evolution_result_text = ""

			_set_mutation_opacity(
				mutation_normal_opacity
			)

		Phase.PLAY:
			selected_card_martyr_cost = 0

		_:
			pass


func _apply_all_ui() -> void:
	_update_phase_label()
	_update_going_first_label()
	_update_phase_shadow_colors()
	_update_round_number_label()
	_update_description()
	_update_end_button()
	_update_draw_buttons()
	_update_mutation_button()


func _update_phase_label() -> void:
	if phase_label == null:
		return

	if current_phase == Phase.NONE:
		phase_label.text = default_phase_text
		return

	phase_label.text = _get_phase_text()


func _update_going_first_label() -> void:
	if going_first_label == null:
		return

	if not has_going_first_value:
		going_first_label.text = default_going_first_text
		return

	if local_player_is_going_first:
		going_first_label.text = "You're Going First"
	else:
		going_first_label.text = "Enemy is Going First"


func _update_phase_shadow_colors() -> void:
	if current_phase == Phase.NONE:
		_set_label_shadow_color(
			phase_label,
			default_phase_shadow_color
		)

		_set_label_shadow_color(
			going_first_label,
			default_going_first_shadow_color
		)

		return

	var shadow_color: Color = _get_phase_shadow_color()

	_set_label_shadow_color(
		phase_label,
		shadow_color
	)

	_set_label_shadow_color(
		going_first_label,
		shadow_color
	)


func _update_round_number_label() -> void:
	if round_number_label == null:
		return

	round_number_label.text = str(
		maxi(round_number, 1)
	)


func _update_description() -> void:
	if description_label == null:
		return

	match current_phase:
		Phase.NONE:
			description_label.text = (
				default_description_text
			)

		Phase.ROUND_INTRO:
			description_label.text = (
				"Round %d begins" % round_number
			)

		Phase.DRAW, Phase.AUTO_DRAW:
			description_label.text = (
				_build_draw_description()
			)

		Phase.EVOLUTION:
			description_label.text = (
				_build_evolution_description()
			)

		Phase.PLAY:
			description_label.text = (
				_build_play_description()
			)

		Phase.WAIT:
			description_label.text = (
				"Enemy is placing cards right now."
			)

		Phase.ATTACK:
			description_label.text = (
				"Combat is resolving"
			)

		Phase.ROUND_END:
			description_label.text = (
				"Round complete"
			)

		Phase.GAME_END:
			description_label.text = game_result_text


func _build_draw_description() -> String:
	var lines: Array[String] = []

	if current_phase == Phase.AUTO_DRAW:
		lines.append(
			"Drawing remaining cards automatically"
		)
	else:
		lines.append("Select cards")

	for entry: String in draw_entries:
		lines.append(entry)

	if draw_is_complete:
		lines.append(
			"Cards revealed next phase"
		)

	return "\n".join(lines)


func _build_evolution_description() -> String:
	if not evolution_result_text.is_empty():
		return evolution_result_text

	if mutation_is_selected:
		return "Select card to evolve"

	return (
		"Click mutation\n"
		+ "Select card to evolve"
	)


func _build_play_description() -> String:
	if selected_card_martyr_cost <= 0:
		return (
			"Select Card\n"
			+ "Choose x martyrs\n"
			+ "Place"
		)

	return (
		"Select Card\n"
		+ "Choose %d martyrs\n"
			% selected_card_martyr_cost
		+ "Place"
	)


func _update_end_button() -> void:
	if end_button == null:
		return

	var is_play_phase: bool = (
		current_phase == Phase.PLAY
	)

	if hide_end_button_outside_play:
		end_button.visible = is_play_phase
	else:
		end_button.visible = true

	end_button.disabled = (
		not is_play_phase
		or end_button_locked
	)


func _update_draw_buttons() -> void:
	var should_show: bool = (
		current_phase == Phase.DRAW
	)

	if worker_button != null:
		worker_button.visible = should_show
		worker_button.disabled = not should_show

	if warrior_button != null:
		warrior_button.visible = should_show
		warrior_button.disabled = not should_show


func _update_mutation_button() -> void:
	if mutation_button == null:
		return

	var should_show: bool = (
		current_phase == Phase.EVOLUTION
	)

	mutation_button.visible = should_show
	mutation_button.disabled = not should_show


func _set_mutation_opacity(opacity: float) -> void:
	if mutation_button == null:
		return

	var new_modulate: Color = mutation_button.modulate

	new_modulate.a = clampf(
		opacity,
		0.0,
		1.0
	)

	mutation_button.modulate = new_modulate


func _get_phase_text() -> String:
	match current_phase:
		Phase.ROUND_INTRO:
			return "ROUND"

		Phase.DRAW, Phase.AUTO_DRAW:
			return "DRAW"

		Phase.EVOLUTION:
			return "EVOLUTION"

		Phase.PLAY:
			return "PLAY"

		Phase.WAIT:
			return "WAIT"

		Phase.ATTACK:
			return "ATTACK"

		Phase.ROUND_END:
			return "ROUND END"

		Phase.GAME_END:
			return "GAME END"

		_:
			return default_phase_text


func _get_phase_shadow_color() -> Color:
	match current_phase:
		Phase.DRAW, Phase.AUTO_DRAW:
			return draw_shadow_color

		Phase.EVOLUTION:
			return evolution_shadow_color

		Phase.PLAY, Phase.WAIT:
			return play_wait_shadow_color

		Phase.ATTACK:
			return attack_shadow_color

		_:
			return other_phase_shadow_color


func _store_inspector_defaults() -> void:
	if phase_label != null:
		default_phase_text = phase_label.text

		if phase_label.label_settings != null:
			default_phase_shadow_color = (
				phase_label.label_settings.shadow_color
			)

	if going_first_label != null:
		default_going_first_text = (
			going_first_label.text
		)

		if going_first_label.label_settings != null:
			default_going_first_shadow_color = (
				going_first_label
				.label_settings
				.shadow_color
			)

	if description_label != null:
		default_description_text = (
			description_label.text
		)


func _prepare_label_settings(label: Label) -> void:
	if label == null:
		return

	var settings: LabelSettings = null

	if label.label_settings == null:
		settings = LabelSettings.new()
	else:
		settings = (
			label.label_settings.duplicate(true)
			as LabelSettings
		)

	label.label_settings = settings


func _set_label_shadow_color(
	label: Label,
	shadow_color: Color
) -> void:
	if label == null:
		return

	if label.label_settings == null:
		_prepare_label_settings(label)

	label.label_settings.shadow_color = shadow_color


func _on_end_button_pressed() -> void:
	if current_phase != Phase.PLAY:
		return

	if end_button_locked:
		return

	end_turn_pressed.emit()
