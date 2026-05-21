extends Node
class_name BackInHandReturnManager

@export var player_hand: NewPlayerHand


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

	var real_card := card as Card

	if real_card == null:
		return

	real_card.death_processed = true

	call_deferred("_deferred_return_card_to_hand", real_card)


func _deferred_return_card_to_hand(card: Card) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if player_hand == null:
		print("BackInHandReturnManager blocked: player_hand is null")
		return

	_force_remove_from_slot(card)

	card.current_health = 1
	card.death_processed = false
	card.current_slot = null

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	player_hand.add_child(card)

	if card in player_hand.player_hand:
		player_hand.update_hand_positions()
	else:
		player_hand.add_card_to_hand(card)

	card.position = Vector2.ZERO
	card.rotation = 0.0
	card.scale = Vector2.ONE
	card.z_index = 0

	if card.has_method("set_selected"):
		card.set_selected(false)

	print("BACK IN HAND returned card: ", card.card_name)


func _force_remove_from_slot(card: Card) -> void:
	var old_slot := card.current_slot

	if old_slot != null and is_instance_valid(old_slot):
		if old_slot.current_card == card:
			old_slot.current_card = null

		if old_slot.has_method("is_empty"):
			print("BackInHand cleared slot. Slot empty now = ", old_slot.is_empty())

	card.current_slot = null
