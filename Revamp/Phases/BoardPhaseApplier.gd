extends Node
class_name BoardPhaseApplier

@export var phase_manager: PhaseManager
@export var slots_root: SlotsRoot

@export var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER

@export var playable_on_lead_play: bool = true
@export var playable_on_response_play: bool = false

@export var apply_on_ready: bool = true


func _ready() -> void:
	if phase_manager == null:
		return

	if not phase_manager.phase_changed.is_connected(_on_phase_changed):
		phase_manager.phase_changed.connect(_on_phase_changed)

	if apply_on_ready:
		apply_phase(phase_manager.get_current_phase())


func apply_phase(phase: PhaseManager.Phase) -> void:
	if slots_root == null:
		return

	if _is_local_play_phase(phase):
		slots_root.show_playable_slots(local_owner)
	else:
		slots_root.show_neutral_slots()


func _is_local_play_phase(phase: PhaseManager.Phase) -> bool:
	if phase == PhaseManager.Phase.LEAD_PLAY:
		return playable_on_lead_play

	if phase == PhaseManager.Phase.RESPONSE_PLAY:
		return playable_on_response_play

	return false


func _on_phase_changed(phase: PhaseManager.Phase) -> void:
	apply_phase(phase)
