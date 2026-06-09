extends Mutation
class_name ColonyNest

@export var worker_ant_data: CardData
@export var amount_to_spawn: int = 1
@export var player_hand_group: String = "player_hand"


func on_damaged(
	card: CardRoot,
	_attacker: CardRoot,
	damage: int
) -> void:
	if damage <= 0:
		return

	_spawn_workers(card)


func on_damaged_context(
	_runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	if context.actual_damage <= 0:
		return

	_spawn_workers(context.target_card)


func _spawn_workers(card: CardRoot) -> void:
	if card == null:
		return

	if worker_ant_data == null:
		return

	var hand := card.get_tree().get_first_node_in_group(player_hand_group) as PlayerHandRoot

	if hand == null:
		print("ColonyNest blocked: no PlayerHandRoot found in group: ", player_hand_group)
		return

	for i in amount_to_spawn:
		if hand.is_full():
			return

		hand.spawn_card(worker_ant_data)
