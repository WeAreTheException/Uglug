extends Mutation
class_name BabyMaker

@export var worker_ant_data: CardData
@export var amount_to_spawn: int = 2
@export var player_hand_group: String = "player_hand"


func on_death(card: CardRoot) -> void:
	if card == null:
		return

	if worker_ant_data == null:
		return

	var tree := card.get_tree()

	if tree == null:
		return

	var hand := tree.get_first_node_in_group(player_hand_group) as PlayerHandRoot

	if hand == null:
		print("BabyMaker blocked: no PlayerHandRoot found in group: ", player_hand_group)
		return

	for i in amount_to_spawn:
		if hand.is_full():
			return

		hand.spawn_card(worker_ant_data)
