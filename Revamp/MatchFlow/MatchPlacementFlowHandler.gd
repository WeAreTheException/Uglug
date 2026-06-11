extends Node
class_name MatchPlacementFlowHandler

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState
@export var placement_controller: PlacementController

@export var print_debug: bool = true


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	match state:
		MatchFlowRoot.MatchState.LEAD_PLACEMENT:
			_apply_owner(_get_lead_owner(), "LEAD_PLACEMENT")

		MatchFlowRoot.MatchState.RESPONSE_PLACEMENT:
			_apply_owner(_get_response_owner(), "RESPONSE_PLACEMENT")


func _apply_owner(owner: SlotRow.SlotOwner, state_name: String) -> void:
	if placement_controller != null:
		placement_controller.set_active_owner(owner)

	if print_debug:
		print(
			"PLACEMENT FLOW: ",
			state_name,
			" | OWNER: ",
			_get_owner_name(owner)
		)


func _get_lead_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.lead_placement_owner


func _get_response_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.OPPONENT

	return turn_order_state.response_placement_owner


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	match owner:
		SlotRow.SlotOwner.PLAYER:
			return "P1"

		SlotRow.SlotOwner.OPPONENT:
			return "P2"

	return "UNKNOWN"
