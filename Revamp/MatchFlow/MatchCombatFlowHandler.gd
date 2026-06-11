extends Node
class_name MatchCombatFlowHandler

signal combat_flow_started(first_owner: SlotRow.SlotOwner)
signal combat_flow_finished

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState
@export var slots_root: SlotsRoot

@export var print_debug: bool = true

var is_running: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state != MatchFlowRoot.MatchState.COMBAT:
		return

	begin_combat_flow()


func begin_combat_flow() -> void:
	if is_running:
		return

	var attack_order_handler := _get_attack_order_handler()

	if attack_order_handler == null:
		print("combat flow blocked: attack_order_handler missing")
		return

	is_running = true

	var first_owner: SlotRow.SlotOwner = _get_attacking_first_owner()
	var second_owner: SlotRow.SlotOwner = _get_opposing_owner(first_owner)

	if print_debug:
		print("COMBAT FLOW STARTED: ", _get_owner_name(first_owner), " FIRST")

	combat_flow_started.emit(first_owner)

	await _run_owner_attack_order(first_owner)
	await _run_owner_attack_order(second_owner)

	is_running = false

	if print_debug:
		print("COMBAT FLOW FINISHED")

	combat_flow_finished.emit()


func _run_owner_attack_order(owner: SlotRow.SlotOwner) -> void:
	var attack_order_handler := _get_attack_order_handler()

	if attack_order_handler == null:
		return

	if print_debug:
		print("COMBAT ATTACK ORDER: ", _get_owner_name(owner))

	attack_order_handler.run_attack_order(owner)

	await attack_order_handler.attack_order_finished


func _get_attack_order_handler() -> AttackOrderHandler:
	if slots_root == null:
		return null

	return slots_root.attack_order_handler


func _get_attacking_first_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.attacking_first_owner


func _get_opposing_owner(owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if turn_order_state != null:
		return turn_order_state.get_opposing_owner(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if turn_order_state != null:
		return turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
