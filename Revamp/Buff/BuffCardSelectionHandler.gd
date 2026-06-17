extends Node
class_name BuffCardSelectionHandler

@export var buff_flow_handler: BuffFlowHandler
@export var selection_state: BuffSelectionState
@export var turn_order_state: MatchTurnOrderState
@export var phase_timer: MatchPhaseTimer

@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot

@export var instruction_label: CanvasItem
@export var instruction_text: String = "Choose one of your warriors to consume the larvae and gain its powers"

@export var print_debug: bool = true

var is_active: bool = false
var selected_card: CardRoot = null


func _ready() -> void:
	_connect_buff_flow()
	_connect_animation_handler()
	_connect_hand(player_one_hand)
	_connect_hand(player_two_hand)
	_set_instruction_visible(false)


func _connect_buff_flow() -> void:
	if buff_flow_handler == null:
		return

	if not buff_flow_handler.buff_started.is_connected(_on_buff_started):
		buff_flow_handler.buff_started.connect(_on_buff_started)

	if not buff_flow_handler.buff_finished.is_connected(_on_buff_finished):
		buff_flow_handler.buff_finished.connect(_on_buff_finished)


func _connect_animation_handler() -> void:
	if buff_flow_handler == null:
		return

	if buff_flow_handler.animation_handler == null:
		return

	var animation_handler := buff_flow_handler.animation_handler

	if not animation_handler.reward_delivery_finished.is_connected(_on_reward_delivery_finished):
		animation_handler.reward_delivery_finished.connect(_on_reward_delivery_finished)


func _connect_hand(hand: PlayerHandRoot) -> void:
	if hand == null:
		return

	if hand.interaction_root == null:
		return

	if not hand.interaction_root.card_left_pressed.is_connected(_on_card_pressed):
		hand.interaction_root.card_left_pressed.connect(_on_card_pressed)


func _on_buff_started(_round_number: int) -> void:
	is_active = true
	selected_card = null

	if selection_state != null:
		selection_state.clear_selections()

	_set_instruction_visible(false)

	if print_debug:
		print("BUFF CARD SELECTION STARTED")


func _on_buff_finished(_round_number: int) -> void:
	is_active = false

	if selected_card != null:
		selected_card.set_prime_select_feedback(false)

	selected_card = null

	if selection_state != null:
		selection_state.clear_selections()

	_set_instruction_visible(false)

	if print_debug:
		print("BUFF CARD SELECTION FINISHED")


func _on_reward_delivery_finished() -> void:
	if not is_active:
		return

	_set_instruction_visible(true)

	if phase_timer != null:
		phase_timer.start_for_state(MatchFlowRoot.MatchState.BUFF)


func _on_card_pressed(card: CardRoot) -> void:
	if not is_active:
		return

	if card == null:
		return

	var owner := _get_owner_for_card(card)

	if not _is_controlled_owner(owner):
		print("Buff selection blocked: not controlled owner")
		return

	var mutation := buff_flow_handler.get_active_reward_mutation()

	if mutation == null:
		print("Buff selection blocked: no active reward mutation")
		return

	if not card.can_receive_buff_mutation(mutation):
		print("Buff selection blocked: card cannot receive mutation")
		return

	if selection_state == null:
		return

	if not selection_state.select_card(owner, card):
		return

	_set_selected_card(card)

	if print_debug:
		print("BUFF CARD SELECTED: ", card.card_name)
		print("BUFF CARD ID: ", card.get_runtime_id())


func _set_selected_card(card: CardRoot) -> void:
	if selected_card != null and selected_card != card:
		selected_card.set_prime_select_feedback(false)

	selected_card = card

	if selected_card != null:
		selected_card.set_prime_select_feedback(true)


func _get_owner_for_card(card: CardRoot) -> SlotRow.SlotOwner:
	if player_one_hand != null and player_one_hand.interaction_root != null:
		if player_one_hand.interaction_root.is_card_in_hand(card):
			return SlotRow.SlotOwner.PLAYER

	return SlotRow.SlotOwner.OPPONENT


func _is_controlled_owner(owner: SlotRow.SlotOwner) -> bool:
	if turn_order_state == null:
		return true

	return turn_order_state.controlled_owner == owner


func _set_instruction_visible(value: bool) -> void:
	if instruction_label == null:
		return

	instruction_label.visible = value

	if value:
		if instruction_label is Label:
			(instruction_label as Label).text = instruction_text

		if instruction_label is RichTextLabel:
			(instruction_label as RichTextLabel).text = instruction_text
