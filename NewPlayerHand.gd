extends Node2D
class_name NewPlayerHand

const CARD_WIDTH = 200
const DEFAULT_CARD_MOVE_SPEED = 0.1
const MAX_HAND_SIZE = 7

var player_hand: Array = []

func add_card_to_hand(card: Node2D, speed := DEFAULT_CARD_MOVE_SPEED) -> void:
	if card not in player_hand:
		player_hand.append(card)
	update_hand_positions(speed)

func remove_card_from_hand(card: Node2D) -> void:
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()

func is_hand_full() -> bool:
	return player_hand.size() >= MAX_HAND_SIZE

func update_hand_positions(speed := DEFAULT_CARD_MOVE_SPEED) -> void:
	for i in range(player_hand.size()):
		var card = player_hand[i]
		var new_position = calculate_card_position(i)

		if "hand_position" in card:
			card.hand_position = new_position

		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index: int) -> Vector2:
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = index * CARD_WIDTH - total_width / 2.0
	return global_position + Vector2(x_offset, 0)

func animate_card_to_position(card: Node2D, new_position: Vector2, speed: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", new_position, speed)
