extends Button
class_name PhaseConfirmButton

@export var buff_flow_handler: BuffFlowHandler
@export var buff_apply_handler: BuffMutationApplyHandler

@export var blessing_flow_handler: BlessingFlowHandler
@export var blessing_apply_handler: BlessingApplyHandler

@export var use_for_buff: bool = false
@export var use_for_blessing: bool = false


func _ready() -> void:
	visible = false
	disabled = true

	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

	if use_for_buff and buff_flow_handler != null:
		if not buff_flow_handler.buff_started.is_connected(_on_phase_started):
			buff_flow_handler.buff_started.connect(_on_phase_started)

		if not buff_flow_handler.buff_finished.is_connected(_on_phase_finished):
			buff_flow_handler.buff_finished.connect(_on_phase_finished)

	if use_for_blessing and blessing_flow_handler != null:
		if not blessing_flow_handler.blessing_started.is_connected(_on_phase_started):
			blessing_flow_handler.blessing_started.connect(_on_phase_started)

		if not blessing_flow_handler.blessing_finished.is_connected(_on_phase_finished):
			blessing_flow_handler.blessing_finished.connect(_on_phase_finished)


func _on_phase_started(_round_number: int = -1) -> void:
	visible = true
	disabled = false


func _on_phase_finished(_round_number: int = -1) -> void:
	visible = false
	disabled = true


func _on_pressed() -> void:
	if use_for_buff and buff_apply_handler != null:
		buff_apply_handler.confirm_buff()
		return

	if use_for_blessing and blessing_apply_handler != null:
		blessing_apply_handler.confirm_blessing()
		return
