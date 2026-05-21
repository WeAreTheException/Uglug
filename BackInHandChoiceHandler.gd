extends Node
class_name BackInHandChoiceHandler

var is_choosing := false
var chosen_card: Card = null


func _ready() -> void:
	add_to_group("back_in_hand_choice_handler")

	GDSync.expose_node(self)
	GDSync.expose_func(request_choose_back_in_hand)
	GDSync.expose_func(commit_choose_back_in_hand)


func start_choice() -> void:
	is_choosing = true
	chosen_card = null

	print("BACK IN HAND: choose one card in your hand")


func choose_card(card: Node2D) -> void:
	if not is_choosing:
		return

	var real_card := card as Card

	if real_card == null:
		return

	if real_card.card_owner != Card.Owner.PLAYER:
		print("Back In Hand blocked: not your card")
		return

	if real_card.current_slot != null:
		print("Back In Hand blocked: card is already on board")
		return

	var snapshot := {
		"card_id": real_card.multiplayer_card_id,
		"owner_peer_id": real_card.owning_peer_id
	}

	if GDSync.is_host():
		commit_choose_back_in_hand(snapshot)
	else:
		GDSync.call_func(request_choose_back_in_hand, snapshot)

	is_choosing = false


func request_choose_back_in_hand(snapshot: Dictionary) -> void:
	if not GDSync.is_host():
		return

	GDSync.call_func_all(commit_choose_back_in_hand, snapshot)


func commit_choose_back_in_hand(snapshot: Dictionary) -> void:
	var card_id := int(snapshot["card_id"])
	var owner_peer_id := int(snapshot["owner_peer_id"])

	var card := _find_card(card_id, owner_peer_id)

	if card == null:
		print("Back In Hand commit blocked: card not found id=", card_id)
		return

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState

	if state == null:
		print("Back In Hand commit blocked: card has no BackInHandCardState")
		return

	state.enable()

	chosen_card = card

	print("BACK IN HAND synced onto: ", card.card_name)


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
