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

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_selected:
				pickup_position = global_position
				is_selected = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_selected:
				global_position = pickup_position
				is_selected = false

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

			if multiplayer.multiplayer_peer == null:
				commit_cut_card(card.multiplayer_card_id)
				return

			if multiplayer.is_server():
				request_cut_card(card.multiplayer_card_id)
			else:
				rpc_id(1, "request_cut_card", card.multiplayer_card_id)

			return

@rpc("any_peer", "call_local", "reliable")
func request_cut_card(card_id: int) -> void:
	if multiplayer.multiplayer_peer != null and not multiplayer.is_server():
		return

	var card := find_card_by_id(card_id)

	if card == null:
		return

	if not card.is_in_group("cuttable_cards"):
		return

	if not _can_requesting_player_cut_card(card):
		print("cut blocked by host: not owner")
		return

	rpc("commit_cut_card", card_id)

@rpc("authority", "call_local", "reliable")
func commit_cut_card(card_id: int) -> void:
	var card := find_card_by_id(card_id)

	if card == null:
		return

	if card.current_slot != null:
		card.current_slot.clear_card()

	card.kill()

func find_card_by_id(card_id: int) -> Card:
	for node in get_tree().get_nodes_in_group("cards"):
		var card := node as Card

		if card != null and card.multiplayer_card_id == card_id:
			return card

	return null

func _can_local_player_cut_card(card: Card) -> bool:
	if multiplayer.multiplayer_peer == null:
		return card.card_owner == Card.Owner.PLAYER

	var my_peer_id := multiplayer.get_unique_id()

	if my_peer_id == 1:
		return card.card_owner == Card.Owner.PLAYER

	return card.card_owner == Card.Owner.OPPONENT

func _can_requesting_player_cut_card(card: Card) -> bool:
	if multiplayer.multiplayer_peer == null:
		return card.card_owner == Card.Owner.PLAYER

	var sender_id := multiplayer.get_remote_sender_id()

	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()

	if sender_id == 1:
		return card.card_owner == Card.Owner.PLAYER

	return card.card_owner == Card.Owner.OPPONENT
