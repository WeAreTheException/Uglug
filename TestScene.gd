extends Node2D

@export var phase_manager: PhaseManager
@export var end_turn_button: Button

func _ready() -> void:
	if end_turn_button != null:
		end_turn_button.pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed() -> void:
	if phase_manager == null:
		return

	phase_manager.end_draw_phase()
