extends Node2D
class_name NewPlayerHand

@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3
@export var normal_draw_amount: int = 2
@export var draw_animation: DeckDrawAnimation

var player_hand: Array = []


func add_card_to_hand(card: Node2D, speed := -1.0) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	_clean_invalid_cards()

	if card not in player_hand:
		player_hand.append(card)

	update_hand_positions(speed)


func remove_card_from_hand(card: Node2D) -> void:
	if card == null:
		return

	_clean_invalid_cards()

	if card in player_hand:
		player_hand.erase(card)

		if draw_animation != null and is_instance_valid(card):
			draw_animation.kill_card_tween(card)

		update_hand_positions()


func is_hand_full() -> bool:
	_clean_invalid_cards()
	return player_hand.size() >= max_hand_size


func get_hand_size() -> int:
	_clean_invalid_cards()
	return player_hand.size()


func get_required_draw_amount() -> int:
	_clean_invalid_cards()

	if player_hand.size() == 0:
		return minimum_hand_size

	return normal_draw_amount


func update_hand_positions(speed := -1.0) -> void:
	if draw_animation == null:
		return

	_clean_invalid_cards()

	for i in range(player_hand.size()):
		var card := player_hand[i] as Node2D

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		var new_position := draw_animation.calculate_card_position(
			global_position,
			player_hand.size(),
			i
		)

		if "hand_position" in card:
			card.hand_position = new_position

		draw_animation.animate_card_to_position(card, new_position, speed)


func get_random_card() -> Card:
	_clean_invalid_cards()

	var valid_cards: Array[Card] = []

	for item in player_hand:
		var card := item as Card

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		valid_cards.append(card)

	if valid_cards.is_empty():
		return null

	return valid_cards.pick_random()


func _clean_invalid_cards() -> void:
	for i in range(player_hand.size() - 1, -1, -1):
		var item = player_hand[i]

		if item == null:
			player_hand.remove_at(i)
			continue

		if not is_instance_valid(item):
			player_hand.remove_at(i)
