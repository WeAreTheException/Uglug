extends Node
class_name BackInHandReturnManager

@export var player_hand: NewPlayerHand
@export var opponent_hand: Node

var returning_cards := {}


func _ready() -> void:
	add_to_group("back_in_hand_return_manager")

	GDSync.expose_node(self)
	GDSync.expose_func(request_return_back_in_hand)
	GDSync.expose_func(commit_return_back_in_hand)


func should_return_to_hand(card: Node2D) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState
	if state == null:
		return false

	return state.is_enabled


func return_card_to_hand(card: Node2D) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	var real_card := card as Card
	if real_card == null:
		return

	var snapshot := {
		"card_id": real_card.multiplayer_card_id,
		"owner_peer_id": real_card.owning_peer_id
	}

	var key := _make_key(snapshot)

	if returning_cards.has(key):
		return

	returning_cards[key] = true
	real_card.death_processed = true

	if GDSync.is_host():
		GDSync.call_func_all(commit_return_back_in_hand, snapshot)
	else:
		GDSync.call_func(request_return_back_in_hand, snapshot)


func request_return_back_in_hand(snapshot: Dictionary) -> void:
	if not GDSync.is_host():
		return

	GDSync.call_func_all(commit_return_back_in_hand, snapshot)


func commit_return_back_in_hand(snapshot: Dictionary) -> void:
	var key := _make_key(snapshot)

	var card_id := int(snapshot["card_id"])
	var owner_peer_id := int(snapshot["owner_peer_id"])

	var card := _find_card(card_id, owner_peer_id)

	if card == null:
		print("BackInHand return blocked: card not found id=", card_id, " owner=", owner_peer_id)
		returning_cards.erase(key)
		return

	_force_return_card(card)

	returning_cards.erase(key)


func _force_return_card(card: Card) -> void:
	_clear_all_slots_holding_card(card)

	card.current_slot = null
	card.current_health = 1
	card.death_processed = false

	if card.has_method("set_selected"):
		card.set_selected(false)

	var target_hand := _get_target_hand(card)

	if target_hand == null:
		print("BackInHand return blocked: target hand is null")
		return

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	target_hand.add_child(card)

	if target_hand.has_method("add_card_to_hand"):
		target_hand.add_card_to_hand(card)
	elif target_hand.has_method("add_card"):
		target_hand.add_card(card)
	else:
		card.position = Vector2.ZERO

	card.current_slot = null
	card.current_health = 1
	card.death_processed = false
	card.visible = true
	card.rotation = 0.0
	card.scale = Vector2.ONE
	card.z_index = 0

	print("BACK IN HAND returned card: ", card.card_name, " owner=", card.owning_peer_id)


func _clear_all_slots_holding_card(card: Card) -> void:
	var scene := get_tree().current_scene

	if scene == null:
		return

	var slots := scene.find_children("*", "NewSlots", true, false)

	for node in slots:
		var slot := node as NewSlots

		if slot == null:
			continue

		if slot.current_card == card:
			slot.current_card = null
			print("BackInHand force-cleared slot lane=", slot.lane_id)

	if card.current_slot != null and is_instance_valid(card.current_slot):
		card.current_slot.current_card = null

	card.current_slot = null


func _get_target_hand(card: Card) -> Node:
	var local_peer_id := int(GDSync.get_client_id())

	if card.owning_peer_id == local_peer_id:
		return player_hand

	return opponent_hand


func _make_key(snapshot: Dictionary) -> String:
	return str(int(snapshot["card_id"])) + "_" + str(int(snapshot["owner_peer_id"]))


func _find_card(card_id: int, owner_peer_id: int) -> Card:
	var scene := get_tree().current_scene

	if scene == null:
		return null

	return _find_card_recursive(scene, card_id, owner_peer_id)


func _find_card_recursive(node: Node, card_id: int, owner_peer_id: int) -> Card:
	var card := node as Card

	if card != null:
		if card.multiplayer_card_id == card_id and card.owning_peer_id == owner_peer_id:
			return card

	for child in node.get_children():
		var found := _find_card_recursive(child, card_id, owner_peer_id)

		if found != null:
			return found

	return null
