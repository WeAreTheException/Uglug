extends Node
class_name BackInHandChoiceHandler

var is_choosing := false
var chosen_card: Node2D = null


func _ready() -> void:
	add_to_group("back_in_hand_choice_handler")

	GDSync.expose_node(self)
	GDSync.expose_func(start_choice)


func start_choice() -> void:
	is_choosing = true
	chosen_card = null

	print("BACK IN HAND: choose one card in your hand")


func choose_card(card: Node2D) -> void:
	if not is_choosing:
		return

	if card == null:
		return

	if not _is_card_in_local_hand(card):
		print("Back In Hand blocked: card is not in local hand")
		return

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState
	if state == null:
		print("Back In Hand blocked: card has no BackInHandCardState")
		return

	state.enable()

	chosen_card = card
	is_choosing = false

	print("BACK IN HAND chosen: ", card.name)


func _is_card_in_local_hand(card: Node2D) -> bool:
	var hand := _find_local_hand()
	if hand == null:
		return false

	if hand.has_method("get") and hand.get("player_hand") is Array:
		return card in hand.get("player_hand")

	return card.get_parent() == hand


func _find_local_hand() -> Node:
	var hands := get_tree().get_nodes_in_group("local_player_hand")
	if hands.size() > 0:
		return hands[0]

	return get_tree().get_first_node_in_group("player_hand")
