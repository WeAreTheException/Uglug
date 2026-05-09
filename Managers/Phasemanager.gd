extends Node
class_name PhaseManager

signal phase_changed(phase_name: String)

enum Phase {
	DRAW,
	PLACE,
	ATTACK
}

@export var turn_manager: TurnManager

@export var place_timer: Timer
@export var place_timer_label: Label

@export var player_one_place_color: Color = Color.WHITE
@export var player_two_place_color: Color = Color.RED

var current_phase: Phase = Phase.DRAW

func _ready() -> void:
	if place_timer == null:
		place_timer = _find_child_timer()

	if place_timer != null:
		place_timer.one_shot = true
		place_timer.timeout.connect(_on_place_timer_timeout)

	if place_timer_label != null:
		place_timer_label.visible = false

func _process(_delta: float) -> void:
	update_place_timer_label()

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

	if current_phase != Phase.PLACE:
		stop_place_timer()

func start_place_timer(is_player_one_turn: bool) -> void:
	if place_timer == null:
		return

	place_timer.stop()
	place_timer.start()

	if place_timer_label != null:
		place_timer_label.visible = true

		if is_player_one_turn:
			place_timer_label.add_theme_color_override("font_color", player_one_place_color)
		else:
			place_timer_label.add_theme_color_override("font_color", player_two_place_color)

	update_place_timer_label()

func stop_place_timer() -> void:
	if place_timer != null:
		place_timer.stop()

	if place_timer_label != null:
		place_timer_label.visible = false

func update_place_timer_label() -> void:
	if place_timer == null:
		return

	if place_timer_label == null:
		return

	if not place_timer_label.visible:
		return

	var seconds_left := int(ceil(place_timer.time_left))
	var minutes := seconds_left / 60
	var seconds := seconds_left % 60

	place_timer_label.text = "%d:%02d" % [minutes, seconds]

func _on_place_timer_timeout() -> void:
	if turn_manager == null:
		return

	if not GDSync.is_host():
		return

	turn_manager.force_done_current_placing_player()

func _find_child_timer() -> Timer:
	for child in get_children():
		if child is Timer:
			return child as Timer

	return null

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
