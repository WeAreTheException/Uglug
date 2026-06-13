extends Node
class_name HandPhaseApplier

@export var phase_manager: PhaseManager

@export var lead_hand: PlayerHandRoot
@export var response_hand: PlayerHandRoot

@export var apply_current_phase_on_ready: bool = true


func _ready() -> void:
	if phase_manager == null:
		return

	if not phase_manager.phase_changed.is_connected(_on_phase_changed):
		phase_manager.phase_changed.connect(_on_phase_changed)

	if apply_current_phase_on_ready:
		apply_phase(phase_manager.get_current_phase())


func apply_phase(phase: PhaseManager.Phase) -> void:
	match phase:
		PhaseManager.Phase.DRAW:
			_set_both_idle()

		PhaseManager.Phase.BUFF:
			_set_both_buff()

		PhaseManager.Phase.LEAD_PLAY:
			_set_lead_playing()

		PhaseManager.Phase.RESPONSE_PLAY:
			_set_response_playing()

		PhaseManager.Phase.ATTACK:
			_set_both_idle()


func _set_both_idle() -> void:
	if lead_hand != null:
		lead_hand.enter_idle_state()

	if response_hand != null:
		response_hand.enter_idle_state()

func _set_both_buff() -> void:
	if lead_hand != null:
		lead_hand.enter_buff_state()

	if response_hand != null:
		response_hand.enter_buff_state()

func _set_both_blessing() -> void:
	if lead_hand != null:
		lead_hand.enter_blessing_state()

	if response_hand != null:
		response_hand.enter_blessing_state()


func _set_lead_playing() -> void:
	if lead_hand != null:
		lead_hand.enter_play_state()

	if response_hand != null:
		response_hand.enter_idle_state()


func _set_response_playing() -> void:
	if lead_hand != null:
		lead_hand.enter_idle_state()

	if response_hand != null:
		response_hand.enter_play_state()


func _on_phase_changed(phase: PhaseManager.Phase) -> void:
	apply_phase(phase)
