extends Node
class_name SacrificeHandler

@export var player_hand_root: PlayerHandRoot


func _ready() -> void:
	if player_hand_root == null:
		return

	if not player_hand_root.card_primed.is_connected(_on_card_primed):
		player_hand_root.card_primed.connect(_on_card_primed)

	if not player_hand_root.card_unprimed.is_connected(_on_card_unprimed):
		player_hand_root.card_unprimed.connect(_on_card_unprimed)


func _on_card_primed(primed_card: CardRoot) -> void:
	if player_hand_root == null:
		return

	for card in player_hand_root.get_cards():
		if card == null:
			continue

		if card == primed_card:
			continue

		card.start_sacrifice_anticipation()


func _on_card_unprimed(_card: CardRoot) -> void:
	_stop_all_hand_anticipation()


func _stop_all_hand_anticipation() -> void:
	if player_hand_root == null:
		return

	for card in player_hand_root.get_cards():
		if card == null:
			continue

		card.stop_sacrifice_anticipation()
