extends Node2D

@export var phase_manager: PhaseManager
@export var end_placement_button: Button

func _ready() -> void:
	if end_placement_button != null:
		end_placement_button.pressed.connect(_on_end_placement_pressed)

func _on_end_placement_pressed() -> void:
	if phase_manager == null:
		return

	phase_manager.end_player_place_phase()
