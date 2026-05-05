extends Label
class_name PhaseLabel

@export var phase_manager: PhaseManager

func _ready() -> void:
	if phase_manager == null:
		return

	if not phase_manager.phase_changed.is_connected(_on_phase_changed):
		phase_manager.phase_changed.connect(_on_phase_changed)

	text = phase_manager.get_phase_name()

func _on_phase_changed(phase_name: String) -> void:
	text = phase_name
