extends Node
class_name CardDeathRouter


func _ready() -> void:
	add_to_group("card_death_router")


func try_handle_death(card: Card) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	if _try_back_in_hand(card):
		return true

	return false


func _try_back_in_hand(card: Card) -> bool:
	var state := card.get_node_or_null("BackInHandCardState") as BackInHandCardState

	if state == null:
		return false

	if not state.is_enabled:
		return false

	var return_manager := get_tree().get_first_node_in_group("back_in_hand_return_manager") as BackInHandReturnManager

	if return_manager == null:
		print("CardDeathRouter blocked: no BackInHandReturnManager found")
		return false

	return_manager.return_card_to_hand(card)
	return true
