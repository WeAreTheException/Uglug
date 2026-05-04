extends Node
class_name PhaseManager

enum Phase {
	WAITING,
	PLACE,
	DONE
}

var current_phase: Phase = Phase.WAITING

func _ready() -> void:
	print("PHASE MANAGER READY")
	current_phase = Phase.PLACE
	print("PHASE: PLACE")

func is_place_phase() -> bool:
	return current_phase == Phase.PLACE

func is_player_place_phase() -> bool:
	return current_phase == Phase.PLACE

func set_done() -> void:
	current_phase = Phase.DONE
	print("PHASE: DONE")
