extends Node
class_name PhaseManager

signal phase_changed(phase_name: String)

enum Phase {
	DRAW,
	PLACE,
	ATTACK
}

@export var turn_manager: TurnManager

@export var draw_timer: Timer
@export var place_timer: Timer
@export var attack_timer: Timer

@export var timer_label: Label

@export var draw_timer_color: Color = Color.WHITE
@export var player_one_place_color: Color = Color.WHITE
@export var player_two_place_color: Color = Color.RED

var current_phase: Phase = Phase.DRAW

func _ready() -> void:
	if draw_timer != null:
		draw_timer.one_shot = true
		draw_timer.timeout.connect(_on_draw_timer_timeout)

	if place_timer != null:
		place_timer.one_shot = true
		place_timer.timeout.connect(_on_place_timer_timeout)

	if attack_timer != null:
		attack_timer.one_shot = true

	if timer_label != null:
		timer_label.visible = false

func _process(_delta: float) -> void:
	update_timer_label()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				if turn_manager != null:
					turn_manager.request_step(Phase.DRAW)

			KEY_2:
				if turn_manager != null:
					turn_manager.request_start_place_phase()

			KEY_3:
				if turn_manager != null:
					turn_manager.request_step(Phase.ATTACK)

			KEY_4:
				if turn_manager != null:
					turn_manager.request_flip_attacking_first()

			KEY_SPACE:
				if turn_manager != null:
					turn_manager.request_done_placing()

func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	phase_changed.emit(get_phase_name())
	print("PHASE CHANGED TO: ", get_phase_name())

	if current_phase == Phase.DRAW:
		start_draw_timer()
	elif current_phase != Phase.PLACE:
		stop_visible_timers()

func start_draw_timer() -> void:
	stop_visible_timers()

	if draw_timer == null:
		return

	draw_timer.start(draw_timer.wait_time)

	if timer_label != null:
		timer_label.visible = true
		timer_label.add_theme_color_override("font_color", draw_timer_color)

	update_timer_label()

func start_place_timer(is_player_one_turn: bool) -> void:
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

	if timer_label != null:
		timer_label.visible = false

func stop_visible_timers() -> void:
	if draw_timer != null:
		draw_timer.stop()

	if place_timer != null:
		place_timer.stop()

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

func get_active_visible_timer() -> Timer:
	if draw_timer != null and not draw_timer.is_stopped():
		return draw_timer

	if place_timer != null and not place_timer.is_stopped():
		return place_timer

	return null

func _on_draw_timer_timeout() -> void:
	if turn_manager == null:
		return

	if not GDSync.is_host():
		return

	turn_manager.start_place_phase()

func _on_place_timer_timeout() -> void:
	if turn_manager == null:
		return

	if not GDSync.is_host():
		return

	turn_manager.force_done_current_placing_player()

func get_phase_name() -> String:
	match current_phase:
		Phase.DRAW:
			return "Draw"
		Phase.PLACE:
			return "Place"
		Phase.ATTACK:
			return "Attack"

	return ""

func is_draw_phase() -> bool:
	return current_phase == Phase.DRAW

func is_place_phase() -> bool:
	return current_phase == Phase.PLACE

func is_player_place_phase() -> bool:
	return current_phase == Phase.PLACE

func is_attack_phase() -> bool:
	return current_phase == Phase.ATTACK
