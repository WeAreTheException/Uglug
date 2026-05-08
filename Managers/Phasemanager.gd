extends Node
class_name PhaseManager

signal phase_changed(phase_name: String)
signal active_player_changed(client_id: int, phase_name: String)

enum Phase {
	DRAW,
	PLACE,
	ATTACK
}

@export var turn_manager: TurnManager

var current_phase: Phase = Phase.DRAW
var active_client_id: int = -1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				if turn_manager != null:
					turn_manager.request_start_auto_turns()

			KEY_4:
				if turn_manager != null:
					turn_manager.request_flip_attacking_first()

func set_phase(new_phase: Phase, new_active_client_id: int = -1) -> void:
	current_phase = new_phase
	active_client_id = new_active_client_id

	var phase_name := get_phase_name()

	phase_changed.emit(phase_name)
	active_player_changed.emit(active_client_id, phase_name)

	print("PHASE CHANGED TO: ", phase_name, " ACTIVE CLIENT: ", active_client_id)

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

func is_my_turn() -> bool:
	if active_client_id == -1:
		return true

	return int(GDSync.get_client_id()) == active_client_id
