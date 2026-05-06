extends Node2D
class_name NewPlayerHand

@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3
@export var normal_draw_amount: int = 2
@export var draw_animation: DeckDrawAnimation

var player_hand: Array = []

func add_card_to_hand(card: Node2D, speed := -1.0) -> void:
	if card not in player_hand:
		player_hand.append(card)

	update_hand_positions(speed)

func remove_card_from_hand(card: Node2D) -> void:
	if card in player_hand:
		player_hand.erase(card)

		if draw_animation != null:
			draw_animation.kill_card_tween(card)

		update_hand_positions()

func is_hand_full() -> bool:
	return player_hand.size() >= max_hand_size

func get_hand_size() -> int:
	return player_hand.size()

func get_required_draw_amount() -> int:
	if player_hand.size() == 0:
		return minimum_hand_size

	return normal_draw_amount

func update_hand_positions(speed := -1.0) -> void:
	if draw_animation == null:
		return

	for i in range(player_hand.size()):
		var card: Node2D = player_hand[i]
		var new_position := draw_animation.calculate_card_position(global_position, player_hand.size(), i)

		if "hand_position" in card:
			card.hand_position = new_position

		draw_animation.animate_card_to_position(card, new_position, speed)
