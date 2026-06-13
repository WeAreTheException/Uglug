extends Node
class_name BuffCardStagingHandler

signal consume_approach_finished(card: CardRoot)
signal power_tremble_midpoint(card: CardRoot)
signal power_tremble_finished(card: CardRoot)

@export var buff_flow_handler: BuffFlowHandler
@export var selection_state: BuffSelectionState
@export var buff_card_location: Node2D

@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot
@export var staging_layer: Node2D

@export_group("Stage Animation")
@export var move_time: float = 0.25
@export var staged_scale: Vector2 = Vector2(1, 1)
@export var staged_rotation_degrees: float = 0.0
@export var staged_z_index: int = 100

@export_group("Consume Rotation Animation")
@export var consume_rotation_time: float = 0.1
@export var consume_rotation_degrees: float = -12.0
@export var consume_scale: Vector2 = Vector2(1, 1)
@export var consume_bite_x_offset: float = 18.0
@export var consume_bite_y_offset: float = 6.0

@export_group("Power Tremble Animation")
@export var power_scale: Vector2 = Vector2(1.18, 1.18)
@export var power_tremble_rotation: float = 4.0
@export var power_tremble_step_time: float = 0.05
@export var power_tremble_cycles: int = 4

@export_group("Return Animation")
@export var return_time: float = 0.35

@export var print_debug: bool = true

var selected_card: CardRoot = null
var selected_card_original_parent: Node = null
var selected_card_original_index: int = -1
var selected_card_original_global_transform: Transform2D
var active_tween: Tween = null
var layer_mover := HandCardLayerMoverHelper.new()


func _ready() -> void:
	if buff_flow_handler != null:
		if not buff_flow_handler.buff_started.is_connected(_on_buff_started):
			buff_flow_handler.buff_started.connect(_on_buff_started)

		if not buff_flow_handler.buff_finished.is_connected(_on_buff_finished):
			buff_flow_handler.buff_finished.connect(_on_buff_finished)

	if selection_state != null:
		if not selection_state.selection_changed.is_connected(_on_selection_changed):
			selection_state.selection_changed.connect(_on_selection_changed)


func stage_card(card: CardRoot) -> void:
	if card == null:
		return

	if buff_card_location == null:
		print("Buff staging blocked: buff_card_location missing")
		return

	_unstage_selected_card(false)

	selected_card = card
	selected_card_original_parent = card.get_parent()
	selected_card_original_index = card.get_index()
	selected_card_original_global_transform = card.global_transform

	if staging_layer != null:
		layer_mover.move_to_layer(card, staging_layer)

	card.z_index = staged_z_index

	if active_tween != null:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_CUBIC)
	active_tween.set_ease(Tween.EASE_OUT)

	active_tween.parallel().tween_property(card, "global_position", buff_card_location.global_position, move_time)
	active_tween.parallel().tween_property(card, "rotation_degrees", staged_rotation_degrees, move_time)
	active_tween.parallel().tween_property(card, "scale", staged_scale, move_time)

	if print_debug:
		print("BUFF CARD STAGED: ", card.card_name)


func play_consume_rotation() -> void:
	if selected_card == null:
		print("Buff consume rotation blocked: no staged card")
		return

	if active_tween != null:
		active_tween.kill()

	var center_position := selected_card.global_position
	var left_position := center_position + Vector2(-consume_bite_x_offset, consume_bite_y_offset)
	var right_position := center_position + Vector2(consume_bite_x_offset, consume_bite_y_offset)

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_CUBIC)
	active_tween.set_ease(Tween.EASE_IN_OUT)

	active_tween.parallel().tween_property(selected_card, "rotation_degrees", consume_rotation_degrees, consume_rotation_time)
	active_tween.parallel().tween_property(selected_card, "global_position", left_position, consume_rotation_time)

	active_tween.tween_property(selected_card, "rotation_degrees", -consume_rotation_degrees, consume_rotation_time)
	active_tween.parallel().tween_property(selected_card, "global_position", right_position, consume_rotation_time)

	active_tween.tween_property(selected_card, "rotation_degrees", consume_rotation_degrees, consume_rotation_time)
	active_tween.parallel().tween_property(selected_card, "global_position", left_position, consume_rotation_time)

	active_tween.tween_property(selected_card, "rotation_degrees", staged_rotation_degrees, consume_rotation_time)
	active_tween.parallel().tween_property(selected_card, "global_position", center_position, consume_rotation_time)

	active_tween.parallel().tween_property(selected_card, "scale", consume_scale, consume_rotation_time * 4.0)

	await active_tween.finished
	consume_approach_finished.emit(selected_card)


func play_power_tremble() -> void:
	if selected_card == null:
		return

	if active_tween != null:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)

	active_tween.tween_property(selected_card, "scale", power_scale, power_tremble_step_time)
	power_tremble_midpoint.emit(selected_card)

	for i in power_tremble_cycles:
		active_tween.tween_property(selected_card, "rotation_degrees", power_tremble_rotation, power_tremble_step_time)
		active_tween.tween_property(selected_card, "rotation_degrees", -power_tremble_rotation, power_tremble_step_time)

	active_tween.tween_property(selected_card, "rotation_degrees", staged_rotation_degrees, power_tremble_step_time)
	active_tween.tween_property(selected_card, "scale", staged_scale, power_tremble_step_time)

	await active_tween.finished
	power_tremble_finished.emit(selected_card)


func unstage_card() -> void:
	await _return_selected_card_to_hand(true)


func get_staged_card() -> CardRoot:
	return selected_card


func set_hand_input_enabled(value: bool) -> void:
	_set_hand_input_enabled(value)


func _return_selected_card_to_hand(restore_input: bool) -> void:
	if active_tween != null:
		active_tween.kill()

	if selected_card == null or not is_instance_valid(selected_card):
		if restore_input:
			_set_hand_input_enabled(true)
		return

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_CUBIC)
	active_tween.set_ease(Tween.EASE_OUT)

	active_tween.parallel().tween_property(selected_card, "global_position", selected_card_original_global_transform.origin, return_time)
	active_tween.parallel().tween_property(selected_card, "rotation", selected_card_original_global_transform.get_rotation(), return_time)
	active_tween.parallel().tween_property(selected_card, "scale", selected_card_original_global_transform.get_scale(), return_time)

	await active_tween.finished

	if selected_card_original_parent != null:
		layer_mover.move_to_layer(selected_card, selected_card_original_parent as Node2D)

	_clear_selected_card_refs()

	if restore_input:
		_set_hand_input_enabled(true)


func _unstage_selected_card(restore_input: bool) -> void:
	if active_tween != null:
		active_tween.kill()

	if selected_card != null and is_instance_valid(selected_card):
		selected_card.global_transform = selected_card_original_global_transform

		if selected_card_original_parent != null:
			layer_mover.move_to_layer(selected_card, selected_card_original_parent as Node2D)

	_clear_selected_card_refs()

	if restore_input:
		_set_hand_input_enabled(true)


func _clear_selected_card_refs() -> void:
	selected_card = null
	selected_card_original_parent = null
	selected_card_original_index = -1


func _on_selection_changed(_slot_owner: SlotRow.SlotOwner, card: CardRoot) -> void:
	if buff_flow_handler == null:
		return

	if not buff_flow_handler.is_active:
		return

	stage_card(card)


func _on_buff_started(_round_number: int) -> void:
	_set_hand_input_enabled(true)


func _on_buff_finished(_round_number: int) -> void:
	_unstage_selected_card(true)


func _set_hand_input_enabled(value: bool) -> void:
	if player_one_hand != null:
		player_one_hand.set_hand_input_enabled(value)

	if player_two_hand != null:
		player_two_hand.set_hand_input_enabled(value)
