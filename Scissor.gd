extends Node2D
class_name Scissor

@export var click_area: Area2D

var is_selected: bool = false
var pickup_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if click_area == null:
		click_area = $Area2D

	click_area.input_event.connect(_on_click_area_input_event)

func _process(_delta: float) -> void:
	if is_selected:
		global_position = get_global_mouse_position()

func _on_click_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_selected:
				pickup_position = global_position
				is_selected = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:

		# return scissors
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_selected:
				global_position = pickup_position
				is_selected = false

		# cut card
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_selected:
				try_cut_card()

func try_cut_card() -> void:
	var space_state = get_world_2d().direct_space_state

	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true

	var results = space_state.intersect_point(params)

	for result in results:
		var collider: Node = result.collider

		if collider == click_area:
			continue

		var target: Node = collider

		if collider.get_parent() is Card:
			target = collider.get_parent()

		if target.is_in_group("cuttable_cards"):

			var card := target as Card

			if card == null:
				return

			if not _can_local_player_cut_card(card):
				print("cut blocked: not your card")
				return

			if card.current_slot != null:
				card.current_slot.clear_card()

			card.kill()

			return

func _can_local_player_cut_card(card: Card) -> bool:
	var my_peer_id := multiplayer.get_unique_id()

	# offline testing
	if multiplayer.multiplayer_peer == null:
		return card.card_owner == Card.Owner.PLAYER

	# host/player 1
	if my_peer_id == 1:
		return card.card_owner == Card.Owner.PLAYER

	# client/player 2
	return card.card_owner == Card.Owner.OPPONENT
