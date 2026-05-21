extends Node
class_name BackInHandReturnManager


func _ready() -> void:
	add_to_group("back_in_hand_return_manager")


func should_return_to_hand(card: Node2D) -> bool:
	if card == null:
		return false

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState
	if state == null:
		return false

	return state.is_enabled


func return_card_to_hand(card: Node2D) -> void:
	if card == null:
		return

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState
	if state != null:
		state.disable()

	var hand := _find_owner_hand(card)

	if hand == null:
		print("BackInHandReturnManager blocked: could not find owner hand")
		return

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand.add_child(card)

	if hand.has_method("add_card_to_hand"):
		hand.add_card_to_hand(card)
	else:
		card.position = Vector2.ZERO

	print("BACK IN HAND returned card: ", card.name)


func _find_owner_hand(card: Node2D) -> Node:
	var owner_peer_id := -1

	if card.has_method("get_owner_peer_id"):
		owner_peer_id = int(card.get_owner_peer_id())
	elif card.get("owner_peer_id") != null:
		owner_peer_id = int(card.get("owner_peer_id"))

	var hands := get_tree().get_nodes_in_group("player_hand")

	for hand in hands:
		if hand.get("owner_peer_id") != null and int(hand.get("owner_peer_id")) == owner_peer_id:
			return hand

	var local_hands := get_tree().get_nodes_in_group("local_player_hand")
	if local_hands.size() > 0:
		return local_hands[0]

	return get_tree().get_first_node_in_group("player_hand")
