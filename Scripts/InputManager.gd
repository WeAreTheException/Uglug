extends Node2D

signal left_mouse_pressed
signal left_mouse_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

@onready var card_manager = $"../CardManager"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_pressed")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_released")

func raycast_at_cursor():
	var space_state = get_viewport().world_2d.direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	
	var result = space_state.intersect_point(parameters)

	if result.is_empty():
		return

	var collider = result[0].collider
	var mask = collider.collision_mask

	if mask == COLLISION_MASK_CARD:
		card_manager.start_drag(collider)

	elif mask == COLLISION_MASK_DECK:
		collider.draw_card()   # direct call (Area2D root)
