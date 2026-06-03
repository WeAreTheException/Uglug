extends Mutation
class_name ColonyNest

@export var worker_ant_data: CardData
@export var workers_per_hit: int = 1
@export var player_hand_group: String = "player_hand"


func on_damaged(
	card: CardRoot,
	_attacker: CardRoot,
	_damage: int
) -> void:
	if card == null:
		return

	if worker_ant_data == null:
		return

	var tree := card.get_tree()

	if tree == null:
		return

	var hand := tree.get_first_node_in_group(player_hand_group) as PlayerHandRoot

	if hand == null:
		print("ColonyNest blocked: no PlayerHandRoot found in group: ", player_hand_group)
		return

	for i in workers_per_hit:
		if hand.is_full():
			return

		hand.spawn_card(worker_ant_data)
