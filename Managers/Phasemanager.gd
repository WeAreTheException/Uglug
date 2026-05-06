extends Node
class_name PhaseManager

signal phase_changed(phase_name: String)

enum Phase {
	DRAW,
	PLACE,
	ATTACK
}

var current_phase: Phase = Phase.DRAW

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
