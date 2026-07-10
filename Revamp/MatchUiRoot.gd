extends Control
class_name MatchUiRoot

signal end_turn_pressed

enum Phase {
	NONE,
	DRAW,
	BUFF,
	PLAY,
	WAIT,
	ATTACK,
}

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

@export_group("Button Text")
@export var worker_text: String = "Worker"
@export var warrior_text: String = "Warrior"
@export var arrow_text: String = "↑"
@export var warrior_arrow_text: String = "→"
@export var buff_text: String = "Buff"
@export var empty_text: String = "X"

@export_group("Button Colors")
@export var active_button_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var inactive_button_color: Color = Color(1.0, 1.0, 1.0, 0.25)
@export var hidden_button_color: Color = Color(1.0, 1.0, 1.0, 0.0)

@export_group("Helper Styling")
@export var draw_number_color: Color = Color.YELLOW
@export var completed_line_alpha: float = 0.35

var current_phase: Phase = Phase.NONE
var round_number: int = 1
var draw_selected_count: int = 0

var buff_start_global_position: Vector2
var is_dragging_buff: bool = false


func _ready() -> void:
	if buff_button != null:
		buff_start_global_position = buff_button.global_position

	_connect_buttons()
	_update_round_label()
	_set_phase(Phase.DRAW)


func _process(_delta: float) -> void:
	if is_dragging_buff and buff_button != null:
		buff_button.global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_R:
			round_number += 1
			_update_round_label()
		KEY_D:
			_set_phase(Phase.DRAW)
		KEY_B:
			_set_phase(Phase.BUFF)
		KEY_P:
			_set_phase(Phase.PLAY)
		KEY_W:
			_set_phase(Phase.WAIT)
		KEY_A:
			_set_phase(Phase.ATTACK)


func _connect_buttons() -> void:
	if worker_button != null:
		worker_button.pressed.connect(_on_worker_pressed)

	if warrior_button != null:
		warrior_button.pressed.connect(_on_warrior_pressed)

	if buff_button != null:
		buff_button.button_down.connect(_on_buff_button_down)
		buff_button.button_up.connect(_on_buff_button_up)

	if timer_end_turn_button != null:
		timer_end_turn_button.pressed.connect(_on_timer_end_turn_pressed)


func _set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	is_dragging_buff = false

	if buff_button != null:
		buff_button.global_position = buff_start_global_position

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
			pass


func _enter_draw_phase() -> void:
	draw_selected_count = 0

	_set_phase_text("Draw")
	_set_helper_text(_draw_helper_text(2))

	_set_button_state(worker_button, worker_text, true, active_button_color)
	_set_button_state(warrior_button, warrior_text, true, active_button_color)
	_set_button_state(buff_button, empty_text, false, inactive_button_color)

	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _enter_buff_phase() -> void:
	_set_phase_text("Buff")
	_set_helper_text(_buff_helper_text(false))

	_set_button_state(worker_button, arrow_text, false, inactive_button_color)
	_set_button_state(warrior_button, warrior_arrow_text, false, inactive_button_color)
	_set_button_state(buff_button, buff_text, true, active_button_color)

	_set_end_turn_enabled(false)
	_set_undo_visible(false)


func _enter_play_phase() -> void:
	_set_phase_text("Play")
	_set_helper_text("Select Card\nChoose x martyrs\nPlace")

	_clear_pile_buttons()

	_set_end_turn_enabled(true)
	_set_undo_visible(false)


func _enter_wait_phase() -> void:
	_set_phase_text("Wait")
	_set_helper_text("Enemy is placing cards right now.")

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

	_add_draw_selection()


func _on_warrior_pressed() -> void:
	if current_phase != Phase.DRAW:
		return

	_add_draw_selection()


func _add_draw_selection() -> void:
	if draw_selected_count >= 2:
		return

	draw_selected_count += 1

	var cards_left := 2 - draw_selected_count

	if cards_left > 0:
		_set_helper_text(_draw_helper_text(cards_left))
	else:
		_set_helper_text("2 cards have been selected\nCards revealed next phase")
		_set_button_enabled(worker_button, false)
		_set_button_enabled(warrior_button, false)


func _on_buff_button_down() -> void:
	if current_phase != Phase.BUFF:
		return

	is_dragging_buff = true
	_set_helper_text(_buff_helper_text(true))


func _on_buff_button_up() -> void:
	if current_phase != Phase.BUFF:
		return

	is_dragging_buff = false

	if buff_button != null:
		buff_button.global_position = buff_start_global_position

	_set_helper_text(_buff_helper_text(false))


func _on_timer_end_turn_pressed() -> void:
	if current_phase != Phase.PLAY:
		return

	end_turn_pressed.emit()


func _draw_helper_text(cards_left: int) -> String:
	return "Draw [color=%s]%s[/color] card%s\nCards revealed next phase" % [
		draw_number_color.to_html(false),
		cards_left,
		"" if cards_left == 1 else "s"
	]


func _buff_helper_text(is_selecting_buff_done: bool) -> String:
	if is_selecting_buff_done:
		return "[color=#ffffff59]Select buff.[/color]\nSelect card to buff."

	return "Select buff.\nSelect card to buff."


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

	round_label.text = "Round %s" % round_number


func _set_button_state(button: Button, text: String, enabled: bool, color: Color) -> void:
	if button == null:
		return

	button.text = text
	button.disabled = not enabled
	button.visible = true
	button.modulate = color


func _set_button_enabled(button: Button, enabled: bool) -> void:
	if button == null:
		return

	button.disabled = not enabled
	button.modulate = active_button_color if enabled else inactive_button_color


func _clear_pile_buttons() -> void:
	_set_button_state(worker_button, "", false, hidden_button_color)
	_set_button_state(warrior_button, "", false, hidden_button_color)
	_set_button_state(buff_button, "", false, hidden_button_color)


func _set_end_turn_enabled(enabled: bool) -> void:
	if timer_end_turn_button == null:
		return

	timer_end_turn_button.disabled = not enabled

	if enabled:
		timer_end_turn_button.text = "End Turn"
		timer_end_turn_button.modulate = active_button_color
	else:
		timer_end_turn_button.text = ""
		timer_end_turn_button.modulate = inactive_button_color


func _set_undo_visible(is_visible: bool) -> void:
	if undo_button == null:
		return

	undo_button.visible = is_visible
