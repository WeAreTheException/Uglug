extends Node
class_name CardRaycastHelper

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

func get_card_under_mouse() -> Node:
	var space_state = get_viewport().world_2d.direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_viewport().get_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = COLLISION_MASK_CARD

	var result = space_state.intersect_point(params)
	if result.size() == 0:
		return null

	return _get_top_card(result)

func get_slot_under_mouse() -> Node:
	var space_state = get_viewport().world_2d.direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_viewport().get_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = COLLISION_MASK_CARD_SLOT

	var result = space_state.intersect_point(params)
	if result.size() == 0:
		return null

	return result[0].collider

func _get_top_card(results) -> Node:
	var best_card = null
	var best_z = -INF
	var best_y = -INF

	for hit in results:
		var card = hit.collider

		if card.z_index > best_z:
			best_card = card
			best_z = card.z_index
			best_y = card.global_position.y
		elif card.z_index == best_z:
			if card.global_position.y > best_y:
				best_card = card
				best_y = card.global_position.y

	return best_card
