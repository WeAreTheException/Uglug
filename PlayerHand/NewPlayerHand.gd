extends Node2D
class_name NewPlayerHand

@export var card_width: float = 200
@export var default_card_move_speed: float = 0.1

@export var max_hand_size: int = 7
@export var minimum_hand_size: int = 3
@export var normal_draw_amount: int = 2

var player_hand: Array = []

func add_card_to_hand(card: Node2D, speed := -1.0) -> void:
	if speed < 0:
		speed = default_card_move_speed

	if card not in player_hand:
		player_hand.append(card)

	update_hand_positions(speed)

func remove_card_from_hand(card: Node2D) -> void:
	if card in player_hand:
		player_hand.erase(card)
		kill_card_tween(card)
		update_hand_positions()

func is_hand_full() -> bool:
	return player_hand.size() >= max_hand_size

func get_hand_size() -> int:
	return player_hand.size()

func needs_minimum_draw() -> bool:
	return player_hand.size() < minimum_hand_size

func get_required_draw_amount() -> int:
	if player_hand.size() == 0:
		return minimum_hand_size

	return normal_draw_amount


func update_hand_positions(speed := -1.0) -> void:
	if speed < 0:
		speed = default_card_move_speed

	for i in range(player_hand.size()):
		var card = player_hand[i]
		var new_position = calculate_card_position(i)

		if "hand_position" in card:
			card.hand_position = new_position

		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index: int) -> Vector2:
	var total_width = (player_hand.size() - 1) * card_width
	var x_offset = index * card_width - total_width / 2.0

	return global_position + Vector2(x_offset, 0)

func animate_card_to_position(card: Node2D, new_position: Vector2, speed: float) -> void:
	kill_card_tween(card)

	var tween = get_tree().create_tween()

	card.set_meta("move_tween", tween)

	tween.tween_property(card, "global_position", new_position, speed)

	tween.finished.connect(func():
		if card.has_meta("move_tween") and card.get_meta("move_tween") == tween:
			card.remove_meta("move_tween")
	)

func kill_card_tween(card: Node2D) -> void:
	if card.has_meta("move_tween"):
		var tween = card.get_meta("move_tween")

		if tween != null:
			tween.kill()

		card.remove_meta("move_tween")
