extends Node
class_name PhaseManager

signal phase_changed(phase: Phase)
signal phase_name_changed(phase_name: String)

enum Phase {
	DRAW,
	BUFF,
	LEAD_PLAY,
	RESPONSE_PLAY,
	ATTACK
}

@export var starting_phase: Phase = Phase.DRAW

@export var enable_debug_keys: bool = true
@export var draw_key: Key = KEY_1
@export var buff_key: Key = KEY_2
@export var lead_play_key: Key = KEY_3
@export var response_play_key: Key = KEY_4
@export var attack_key: Key = KEY_5

var current_phase: Phase = Phase.DRAW


func _ready() -> void:
	set_phase(starting_phase, true)


func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed:
		return

	if key_event.echo:
		return

	if key_event.keycode == draw_key:
		set_phase(Phase.DRAW)

	if key_event.keycode == buff_key:
		set_phase(Phase.BUFF)

	if key_event.keycode == lead_play_key:
		set_phase(Phase.LEAD_PLAY)

	if key_event.keycode == response_play_key:
		set_phase(Phase.RESPONSE_PLAY)

	if key_event.keycode == attack_key:
		set_phase(Phase.ATTACK)


func set_phase(phase: Phase, force_emit: bool = false) -> void:
	if current_phase == phase and not force_emit:
		return

	current_phase = phase

	phase_changed.emit(current_phase)
	phase_name_changed.emit(get_current_phase_name())


func get_current_phase() -> Phase:
	return current_phase


func get_current_phase_name() -> String:
	return get_phase_name(current_phase)


func get_phase_name(phase: Phase) -> String:
	match phase:
		Phase.DRAW:
			return "Draw"

		Phase.BUFF:
			return "Buff"

		Phase.LEAD_PLAY:
			return "LeadPlay"

		Phase.RESPONSE_PLAY:
			return "ResponsePlay"

		Phase.ATTACK:
			return "Attack"

	return "Unknown"
