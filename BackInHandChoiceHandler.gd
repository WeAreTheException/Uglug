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

	if not _is_valid_choice(card):
		print("Back In Hand blocked: invalid card choice")
		return

	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState
	if state == null:
		print("Back In Hand blocked: card has no BackInHandCardState")
		return

	state.enable()

	chosen_card = card
	is_choosing = false

	print("BACK IN HAND chosen: ", card.name)


func _is_valid_choice(card: Node2D) -> bool:
	if card == null:
		return false

	if card is Card:
		var real_card := card as Card

		if real_card.card_owner != Card.Owner.PLAYER:
			return false

		if real_card.current_slot != null:
			return false

		return true

	return false
