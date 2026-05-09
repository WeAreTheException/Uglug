extends Node
class_name PhaseManager

signal phase_changed(phase_name: String)

enum Phase {
	DRAW,
	PLACE,
	ATTACK
}

@export var turn_manager: TurnManager

var current_phase: Phase = Phase.DRAW

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
