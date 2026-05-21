extends Node
class_name BackInHandDirectDamageBlocker

var blocked_lanes := {}


func _ready() -> void:
	add_to_group("back_in_hand_direct_damage_blocker")


func block_lane(lane_id: int) -> void:
	blocked_lanes[lane_id] = true
	print("BackInHand blocked direct damage lane=", lane_id)

	await get_tree().create_timer(1.0).timeout

	blocked_lanes.erase(lane_id)


func should_block_lane(lane_id: int) -> bool:
	return blocked_lanes.has(lane_id)
