extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var screen_size
var card_being_dragged = null
var is_hovering_on_card: bool = false
@onready var player_hand = $"../PlayerHand"

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if card_being_dragged: # bug fix
				finish_drag()

# -------------------------
# DRAG
# -------------------------

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)

func finish_drag():
	var slot = raycast_check_for_card_slot()

	if slot and not slot.card_in_slot:
		card_being_dragged.global_position = slot.global_position
		
		card_being_dragged.get_node("CollisionShape2D").disabled = true
		slot.card_in_slot = true
		
		player_hand.remove_card_from_hand(card_being_dragged)

	else:
		player_hand.add_card_to_hand(card_being_dragged)

	if card_being_dragged:
		card_being_dragged.scale = Vector2(1.05, 1.05)

	card_being_dragged = null

# -------------------------
# SLOT RAYCAST
# -------------------------

func raycast_check_for_card_slot():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT

	var result = space_state.intersect_point(parameters)

	if result.size() == 0:
		return null

	return result[0].collider  # IMPORTANT: no get_parent()

# -------------------------
# HOVER SIGNAL CONNECTION
# -------------------------

func connect_card_signals(card):
	card.connect("hovered", Callable(self, "_on_hovered_over_card"))
	card.connect("hovered_off", Callable(self, "_on_hovered_off_card"))

func _on_hovered_over_card(card):
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func _on_hovered_off_card(card):
	if not card_being_dragged:
		highlight_card(card, false)
		var new_card = raycast_check_for_card()
		if new_card:
			highlight_card(new_card, true)
		else:
			is_hovering_on_card = false

# -------------------------
# HIGHLIGHT
# -------------------------

func highlight_card(card, hovered: bool):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 10
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

# -------------------------
# CARD RAYCAST
# -------------------------

func raycast_check_for_card():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD

	var result = space_state.intersect_point(parameters)

	if result.size() == 0:
		return null

	return get_card_with_highest_z_index(result)

func get_card_with_highest_z_index(results):
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
