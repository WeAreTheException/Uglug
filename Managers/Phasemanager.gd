extends Node
class_name PhaseManager

signal phase_changed(phase_name: String)

enum Phase {
	DRAW,
	BUFF,
	PLACE,
	ATTACK
}

@export var turn_manager: Node

@export var draw_timer: Timer
@export var buff_timer: Timer
@export var place_timer: Timer
@export var attack_timer: Timer

@export var timer_label: Label
@export var phase_change_feedback: PhaseChangeFeedback

@export var draw_timer_color: Color = Color.WHITE
@export var buff_timer_color: Color = Color.YELLOW
@export var player_one_place_color: Color = Color.WHITE
@export var player_two_place_color: Color = Color.RED

@export var skip_draw_and_buff_on_turn_one: bool = true

@export var phase_change_sfx: AudioStream
@export var low_time_sfx: AudioStream
@export var sfx_volume_db: float = 0.0
@export var low_time_threshold: float = 10.0

var current_phase: Phase = Phase.PLACE
var turn_number: int = 1
var has_started_match_phases := false

var phase_audio_player: AudioStreamPlayer
var low_time_audio_player: AudioStreamPlayer
var low_time_sound_active := false


func _ready() -> void:
	phase_audio_player = AudioStreamPlayer.new()
	add_child(phase_audio_player)
	phase_audio_player.volume_db = sfx_volume_db

	low_time_audio_player = AudioStreamPlayer.new()
	add_child(low_time_audio_player)
	low_time_audio_player.volume_db = sfx_volume_db

	if draw_timer != null:
		draw_timer.one_shot = true
		draw_timer.timeout.connect(_on_draw_timer_timeout)

	if buff_timer != null:
		buff_timer.one_shot = true
		buff_timer.timeout.connect(_on_buff_timer_timeout)

	if place_timer != null:
		place_timer.one_shot = true
		place_timer.timeout.connect(_on_place_timer_timeout)

	if attack_timer != null:
		attack_timer.one_shot = true

	if timer_label != null:
		timer_label.visible = false


func _process(_delta: float) -> void:
	update_timer_label()
	update_low_time_sfx()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				if turn_manager != null:
					turn_manager.call("request_step", Phase.DRAW)

			KEY_2:
				if turn_manager != null:
					turn_manager.call("request_step", Phase.BUFF)

			KEY_3:
				if turn_manager != null:
					turn_manager.call("request_start_place_phase")

			KEY_4:
				if turn_manager != null:
					turn_manager.call("request_step", Phase.ATTACK)

			KEY_5:
				if turn_manager != null:
					turn_manager.call("request_flip_attacking_first")

			KEY_SPACE:
				if turn_manager != null:
					turn_manager.call("request_done_placing")


func start_match_phases() -> void:
	if has_started_match_phases:
		return

	has_started_match_phases = true

	if not GDSync.is_host():
		return

	turn_number = 1

	if skip_draw_and_buff_on_turn_one:
		if turn_manager != null:
			turn_manager.call("request_start_place_phase")
		else:
			set_phase(Phase.PLACE)
	else:
		if turn_manager != null:
			turn_manager.call("request_step", Phase.DRAW)
		else:
			set_phase(Phase.DRAW)


func set_phase(new_phase: Phase) -> void:
	if skip_draw_and_buff_on_turn_one and turn_number == 1:
		if new_phase == Phase.DRAW or new_phase == Phase.BUFF:
			print("Turn 1 skipped phase: ", get_phase_name_from_value(new_phase))
			set_phase(Phase.PLACE)
			return

	current_phase = new_phase

	play_phase_change_sfx()
	stop_low_time_sfx()
	stop_visible_timers()

	phase_changed.emit(get_phase_name())
	print("PHASE CHANGED TO: ", get_phase_name())

	if current_phase == Phase.DRAW:
		start_draw_timer()
	elif current_phase == Phase.BUFF:
		start_buff_timer()
	elif current_phase == Phase.ATTACK:
		stop_visible_timers()

		if turn_number == 1:
			turn_number = 2
			print("TURN NUMBER: ", turn_number)
	elif current_phase == Phase.PLACE:
		pass
	else:
		stop_visible_timers()


func wait_for_phase_feedback() -> void:
	if phase_change_feedback == null:
		return

	if phase_change_feedback.is_playing_feedback:
		await phase_change_feedback.feedback_finished


func start_draw_timer() -> void:
	await wait_for_phase_feedback()

	stop_visible_timers()

	if draw_timer == null:
		return

	draw_timer.start(draw_timer.wait_time)

	if timer_label != null:
		timer_label.visible = true
		timer_label.add_theme_color_override("font_color", draw_timer_color)

	update_timer_label()


func start_buff_timer() -> void:
	await wait_for_phase_feedback()

	stop_visible_timers()

	if buff_timer == null:
		return

	buff_timer.start(buff_timer.wait_time)

	if timer_label != null:
		timer_label.visible = true
		timer_label.add_theme_color_override("font_color", buff_timer_color)

	update_timer_label()


func start_place_timer(is_player_one_turn: bool) -> void:
	await wait_for_phase_feedback()

	stop_visible_timers()

	if place_timer == null:
		return

	place_timer.start(place_timer.wait_time)

	if timer_label != null:
		timer_label.visible = true

		if is_player_one_turn:
			timer_label.add_theme_color_override("font_color", player_one_place_color)
		else:
			timer_label.add_theme_color_override("font_color", player_two_place_color)

	update_timer_label()


func stop_place_timer() -> void:
	if place_timer != null:
		place_timer.stop()

	stop_low_time_sfx()

	if timer_label != null:
		timer_label.visible = false


func stop_visible_timers() -> void:
	if draw_timer != null:
		draw_timer.stop()

	if buff_timer != null:
		buff_timer.stop()

	if place_timer != null:
		place_timer.stop()

	stop_low_time_sfx()

	if timer_label != null:
		timer_label.visible = false


func stop_all_timers() -> void:
	stop_visible_timers()

	if attack_timer != null:
		attack_timer.stop()


func wait_attack_timer() -> void:
	if attack_timer == null:
		return

	attack_timer.stop()
	attack_timer.start(attack_timer.wait_time)
	await attack_timer.timeout


func update_timer_label() -> void:
	if timer_label == null:
		return

	if not timer_label.visible:
		return

	var active_timer := get_active_visible_timer()

	if active_timer == null:
		return

	var seconds_left := int(ceil(active_timer.time_left))
	var minutes := seconds_left / 60
	var seconds := seconds_left % 60

	timer_label.text = "%d:%02d" % [minutes, seconds]


func update_low_time_sfx() -> void:
	var active_timer := get_active_visible_timer()

	if active_timer == null:
		stop_low_time_sfx()
		return

	if active_timer.time_left <= low_time_threshold and active_timer.time_left > 0.0:
		start_low_time_sfx()
	else:
		stop_low_time_sfx()


func start_low_time_sfx() -> void:
	if low_time_sound_active:
		return

	if low_time_sfx == null:
		return

	low_time_sound_active = true
	low_time_audio_player.stream = low_time_sfx
	low_time_audio_player.play()


func stop_low_time_sfx() -> void:
	low_time_sound_active = false

	if low_time_audio_player != null:
		low_time_audio_player.stop()


func play_phase_change_sfx() -> void:
	if phase_change_sfx == null:
		return

	phase_audio_player.stream = phase_change_sfx
	phase_audio_player.play()


func get_active_visible_timer() -> Timer:
	if draw_timer != null and not draw_timer.is_stopped():
		return draw_timer

	if buff_timer != null and not buff_timer.is_stopped():
		return buff_timer

	if place_timer != null and not place_timer.is_stopped():
		return place_timer

	return null


func _on_draw_timer_timeout() -> void:
	if turn_manager == null:
		return

	if not GDSync.is_host():
		return

	turn_manager.call("request_step", Phase.BUFF)


func _on_buff_timer_timeout() -> void:
	if turn_manager == null:
		return

	if not GDSync.is_host():
		return

	turn_manager.call("start_place_phase")


func _on_place_timer_timeout() -> void:
	if turn_manager == null:
		return

	if not GDSync.is_host():
		return

	turn_manager.call("force_done_current_placing_player")


func get_phase_name() -> String:
	return get_phase_name_from_value(current_phase)


func get_phase_name_from_value(phase_value: Phase) -> String:
	match phase_value:
		Phase.DRAW:
			return "Draw"
		Phase.BUFF:
			return "Buff"
		Phase.PLACE:
			return "Place"
		Phase.ATTACK:
			return "Attack"

	return ""


func is_draw_phase() -> bool:
	return current_phase == Phase.DRAW


func is_buff_phase() -> bool:
	return current_phase == Phase.BUFF


func is_place_phase() -> bool:
	return current_phase == Phase.PLACE


func is_player_place_phase() -> bool:
	return current_phase == Phase.PLACE


func is_attack_phase() -> bool:
	return current_phase == Phase.ATTACK
