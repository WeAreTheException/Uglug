extends Node
class_name MatchTurnOrderState

signal active_owner_changed(owner: SlotRow.SlotOwner)
signal controlled_owner_changed(owner: SlotRow.SlotOwner)
signal attacking_first_owner_changed(owner: SlotRow.SlotOwner)

@export var starting_attacking_first_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var starting_controlled_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var flip_attacking_first_each_round: bool = true

var attacking_first_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var lead_placement_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var response_placement_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.OPPONENT
var active_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var controlled_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER


func setup_for_match() -> void:
	attacking_first_owner = starting_attacking_first_owner
	controlled_owner = starting_controlled_owner
	_apply_attacking_first_owner(attacking_first_owner)
	set_active_owner(attacking_first_owner)


func setup_for_round(round_number: int) -> void:
	var next_attacking_owner := starting_attacking_first_owner

	if flip_attacking_first_each_round and round_number % 2 == 0:
		next_attacking_owner = get_opposing_owner(starting_attacking_first_owner)

	_apply_attacking_first_owner(next_attacking_owner)
	set_active_owner(attacking_first_owner)


func set_active_owner(owner: SlotRow.SlotOwner) -> void:
	if active_owner == owner:
		return

	active_owner = owner
	active_owner_changed.emit(active_owner)


func set_controlled_owner(owner: SlotRow.SlotOwner) -> void:
	if controlled_owner == owner:
		return

	controlled_owner = owner
	controlled_owner_changed.emit(controlled_owner)


func swap_controlled_owner() -> void:
	set_controlled_owner(get_opposing_owner(controlled_owner))


func get_opposing_owner(owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER


func get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"


func _apply_attacking_first_owner(owner: SlotRow.SlotOwner) -> void:
	attacking_first_owner = owner
	lead_placement_owner = owner
	response_placement_owner = get_opposing_owner(owner)
	attacking_first_owner_changed.emit(attacking_first_owner)

func get_active_owner() -> SlotRow.SlotOwner:
	return active_owner


func get_controlled_owner() -> SlotRow.SlotOwner:
	return controlled_owner


func get_attacking_first_owner() -> SlotRow.SlotOwner:
	return attacking_first_owner


func get_lead_placement_owner() -> SlotRow.SlotOwner:
	return lead_placement_owner

func get_response_placement_owner() -> SlotRow.SlotOwner:
	return response_placement_owner
