extends Node
class_name BuffMutationApplyHandler

signal buff_applied(card: CardRoot, mutation: Mutation)

@export var buff_flow_handler: BuffFlowHandler
@export var selection_state: BuffSelectionState
@export var turn_order_state: MatchTurnOrderState
@export var staging_handler: BuffCardStagingHandler
@export var match_network_root: MatchNetworkRoot

@export var return_delay_after_buff: float = 0.35

@export var enable_debug_confirm_key: bool = true
@export var debug_confirm_key: Key = KEY_ENTER
@export var print_debug: bool = true

var is_active: bool = false
var has_confirmed: bool = false


func _ready() -> void:
	if buff_flow_handler == null:
		return

	if not buff_flow_handler.buff_started.is_connected(_on_buff_started):
		buff_flow_handler.buff_started.connect(_on_buff_started)

	if not buff_flow_handler.buff_finished.is_connected(_on_buff_finished):
		buff_flow_handler.buff_finished.connect(_on_buff_finished)


func _input(event: InputEvent) -> void:
	if not enable_debug_confirm_key:
		return

	if not is_active:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == debug_confirm_key:
		confirm_buff()


func confirm_buff() -> bool:
	if not is_active:
		return false

	if has_confirmed:
		print("Buff confirm blocked: already confirmed")
		return false

	if buff_flow_handler == null or selection_state == null:
		return false

	if staging_handler == null:
		print("Buff confirm blocked: staging_handler missing")
		return false

	var mutation := buff_flow_handler.get_active_reward_mutation()

	if mutation == null:
		print("Buff confirm blocked: no reward mutation")
		return false

	var owner := _get_controlled_owner()
	var card := selection_state.get_selected_card(owner)

	if card == null:
		print("Buff confirm blocked: no selected card")
		return false

	if not card.can_receive_buff_mutation(mutation):
		print("Buff confirm blocked: card cannot receive mutation")
		return false

	has_confirmed = true
	staging_handler.set_hand_input_enabled(false)

	await staging_handler.play_consume_rotation()

	if buff_flow_handler.animation_handler != null:
		buff_flow_handler.animation_handler.hide_reward_display()

	await staging_handler.play_power_tremble()

	if match_network_root != null:
		match_network_root.request_buff_confirm(
			owner,
			card.get_runtime_id(),
			mutation.get_safe_mutation_id()
		)

		if print_debug:
			print("BUFF CONFIRM REQUEST SENT: ", mutation.mutation_name, " -> ", card.card_name)
			print("BUFF CONFIRM CARD ID: ", card.get_runtime_id())
	else:
		var applied := card.add_buff_mutation(mutation)

		if not applied:
			print("Buff apply blocked: add failed")
			has_confirmed = false
			staging_handler.set_hand_input_enabled(true)
			return false

		buff_applied.emit(card, mutation)

		if print_debug:
			print("BUFF APPLIED LOCAL: ", mutation.mutation_name, " -> ", card.card_name)

	await _finish_after_apply()
	return true


func _finish_after_apply() -> void:
	if selection_state != null:
		selection_state.clear_selections()

	if return_delay_after_buff > 0.0:
		await get_tree().create_timer(return_delay_after_buff).timeout

	if staging_handler != null:
		await staging_handler.unstage_card()

	if buff_flow_handler != null:
		buff_flow_handler.finish_buff_flow()


func _on_buff_started(_round_number: int) -> void:
	is_active = true
	has_confirmed = false


func _on_buff_finished(_round_number: int) -> void:
	is_active = false
	has_confirmed = false


func _get_controlled_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.controlled_owner
