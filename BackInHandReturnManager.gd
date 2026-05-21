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

	_remove_from_board_now(real_card)

	call_deferred("_finish_return_after_attack_stack", real_card)


func _remove_from_board_now(card: Card) -> void:
	var old_slot := card.current_slot

	if old_slot != null and is_instance_valid(old_slot):
		if old_slot.current_card == card:
			old_slot.current_card = null

		print("BackInHand cleared slot. Slot empty now = ", old_slot.is_empty())

	card.current_slot = null
	card.current_health = 1

	card.visible = false

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	get_tree().current_scene.add_child(card)


func _finish_return_after_attack_stack(card: Card) -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	if card == null:
		return

	if not is_instance_valid(card):
		return

	if player_hand == null:
		print("BackInHandReturnManager blocked: player_hand is null")
		card.visible = true
		return

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	player_hand.add_child(card)

	if card in player_hand.player_hand:
		player_hand.update_hand_positions()
	else:
		player_hand.add_card_to_hand(card)

	card.current_slot = null
	card.current_health = 1
	card.death_processed = false

	card.visible = true
	card.rotation = 0.0
	card.scale = Vector2.ONE
	card.z_index = 0

	if card.has_method("set_selected"):
		card.set_selected(false)

	print("BACK IN HAND finished return: ", card.card_name)
