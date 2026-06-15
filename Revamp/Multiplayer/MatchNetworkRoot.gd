extends Node
class_name MatchNetworkRoot

@export var match_flow_root: MatchFlowRoot
@export var deck_system_root: DeckSystemRoot
@export var turn_order_state: MatchTurnOrderState
@export var match_score_state: MatchScoreState
@export var print_debug := true

var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER


func _ready() -> void:
	_assign_local_owner()
	_print_network_status()


func is_host() -> bool:
	return GDSync.is_host()


func is_client() -> bool:
	return not GDSync.is_host()


func get_local_client_id() -> int:
	return GDSync.get_client_id()


func _assign_local_owner() -> void:
	if is_host():
		local_owner = SlotRow.SlotOwner.PLAYER
	else:
		local_owner = SlotRow.SlotOwner.OPPONENT

	if turn_order_state != null:
		turn_order_state.set_controlled_owner(local_owner)

func _print_network_status() -> void:
	if not print_debug:
		return

	if is_host():
		print("MATCH NETWORK: HOST")
		print("LOCAL OWNER: P1")
	else:
		print("MATCH NETWORK: CLIENT")
		print("LOCAL OWNER: P2")


func get_local_owner() -> SlotRow.SlotOwner:
	return local_owner
