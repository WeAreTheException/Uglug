extends Mutation
class_name BabyMaker

@export var amount_to_spawn: int = 2
@export var respect_hand_limit: bool = false


func on_death_started_context(
	_runtime: MutationRuntime,
	context: DeathContext
) -> void:
	if context == null:
		return

	_spawn_workers(context.dead_card)


func on_death(_card: CardRoot) -> void:
	pass


func _spawn_workers(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.deck_system_root == null:
		print("BabyMaker blocked: card.deck_system_root missing")
		return

	card.deck_system_root.spawn_workers_from_effect_for_card_owner(
		card,
		amount_to_spawn,
		respect_hand_limit
	)
