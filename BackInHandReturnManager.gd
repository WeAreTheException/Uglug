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

	# --- CLEAR BOARD STATE ---

	var old_slot := real_card.current_slot

	if old_slot != null and is_instance_valid(old_slot):
		old_slot.current_card = null

	real_card.current_slot = null

	# --- RESET CARD STATE ---

	real_card.current_health = 1
	real_card.death_processed = false

	# --- REMOVE EFFECT ---

	var state := real_card.get_node_or_null("BackInHandCardState") as BackInHandCardState

	if state != null:
		state.disable()

	# --- MOVE TO HAND ---

	if player_hand == null:
		print("BackInHandReturnManager blocked: player_hand is null")
		return

	if real_card.get_parent() != null:
		real_card.get_parent().remove_child(real_card)

	player_hand.add_child(real_card)
	player_hand.add_card_to_hand(real_card)

	# --- RESET VISUALS ---

	if real_card.has_method("set_selected"):
		real_card.set_selected(false)

	print("BACK IN HAND returned card: ", real_card.card_name)


func _clear_slot(card: Card) -> void:
	if card.current_slot == null:
		return

	var slot := card.current_slot

	if not is_instance_valid(slot):
		card.current_slot = null
		return

	if slot.get("current_card") == card:
		slot.set("current_card", null)

	if slot.has_method("clear_card"):
		slot.clear_card()
	elif slot.has_method("remove_card"):
		slot.remove_card()

	card.current_slot = null


func _restore_health(card: Card) -> void:
	var max_health := 1

	if card.get("max_health") != null:
		max_health = int(card.get("max_health"))
	elif card.get("base_health") != null:
		max_health = int(card.get("base_health"))
	elif card.get("card_data") != null and card.get("card_data") != null:
		var data = card.get("card_data")
		if data.get("health") != null:
			max_health = int(data.get("health"))

	card.current_health = max_health

	if card.has_method("refresh_stats"):
		card.refresh_stats()
	elif card.has_method("update_stats"):
		card.update_stats()
