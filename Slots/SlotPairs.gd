extends Node2D
class_name SlotPair

@export var lane_id: int = 0
@export var player_slot: NewSlots
@export var opponent_slot: NewSlots

func _ready() -> void:
	if player_slot != null:
		player_slot.lane_id = lane_id
		player_slot.slot_owner = NewSlots.SlotOwner.PLAYER
		player_slot.opposing_slot = opponent_slot

	if opponent_slot != null:
		opponent_slot.lane_id = lane_id
		opponent_slot.slot_owner = NewSlots.SlotOwner.OPPONENT
		opponent_slot.opposing_slot = player_slot
