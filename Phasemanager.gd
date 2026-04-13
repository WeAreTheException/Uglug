extends Node
class_name PhaseManager

enum Phase {
	DRAW,
	PLACE
}

var current_phase: Phase = Phase.DRAW

func is_draw_phase() -> bool:
	return current_phase == Phase.DRAW

func is_place_phase() -> bool:
	return current_phase == Phase.PLACE

func end_draw_phase() -> void:
	current_phase = Phase.PLACE
	print("PLACE PHASE")
