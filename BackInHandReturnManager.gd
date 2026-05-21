extends Node
class_name BackInHandReturnManager


func _ready() -> void:
	add_to_group("back_in_hand_return_manager")


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

	var hand := _find_return_hand()

	if hand == null:
		print("BackInHandReturnManager blocked: could not find return hand")
		return

	var old_slot = card.get("current_slot")

	if old_slot != null and is_instance_valid(old_slot):
		if old_slot.get("current_card") == card:
			old_slot.set("current_card", null)

	card.set("current_slot", null)

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState
	if state != null:
		state.disable()

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand.add_child(card)

	if hand.has_method("add_card_to_hand"):
		hand.add_card_to_hand(card)
	else:
		card.position = Vector2.ZERO

	if card.has_method("set_selected"):
		card.set_selected(false)

	print("BACK IN HAND returned card: ", card.name)


func _find_return_hand() -> Node:
	var hand := get_tree().get_first_node_in_group("local_player_hand")
	if hand != null:
		return hand

	hand = get_tree().get_first_node_in_group("player_hand")
	if hand != null:
		return hand

	var all_nodes := get_tree().root.find_children("*", "NewPlayerHand", true, false)

	if all_nodes.size() > 0:
		return all_nodes[0]

	return null
