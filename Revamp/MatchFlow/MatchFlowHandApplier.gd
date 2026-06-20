extends Node
class_name MatchFlowHandApplier

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState

@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot

@export var apply_current_state_on_ready := true


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)

	if apply_current_state_on_ready:
		apply_state(match_flow_root.current_state)


func apply_state(state: MatchFlowRoot.MatchState) -> void:
	_set_both_idle()

	match state:
		MatchFlowRoot.MatchState.BLESSING:
			_set_controlled_hand_blessing()

		MatchFlowRoot.MatchState.BUFF:
			_set_controlled_hand_buff()

		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			_set_active_hand_playing()

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			_set_active_hand_playing()


func _set_both_idle() -> void:
	if player_one_hand != null:
		player_one_hand.enter_idle_state()

	if player_two_hand != null:
		player_two_hand.enter_idle_state()


func _set_controlled_hand_buff() -> void:
	var hand := _get_hand_for_owner(_get_controlled_owner())

	if hand != null:
		hand.enter_buff_state()


func _set_controlled_hand_blessing() -> void:
	var hand := _get_hand_for_owner(_get_controlled_owner())

	if hand != null:
		hand.enter_blessing_state()


func _set_active_hand_playing() -> void:
	var hand := _get_hand_for_owner(_get_active_owner())

	if hand != null:
		hand.enter_play_state()


func _get_active_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.get_active_owner()


func _get_controlled_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.get_controlled_owner()


func _get_hand_for_owner(owner: SlotRow.SlotOwner) -> PlayerHandRoot:
	if owner == SlotRow.SlotOwner.PLAYER:
		return player_one_hand

	return player_two_hand


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	apply_state(state)
