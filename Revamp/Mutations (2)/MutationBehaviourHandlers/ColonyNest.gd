extends Mutation
class_name ColonyNest

@export var workers_per_hit: int = 2
@export var respect_hand_limit: bool = false


func on_struck_context(
	runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	_spawn_workers(runtime, context.target_card)


func on_struck(
	card: CardRoot,
	_attacker: CardRoot,
	_damage: int
) -> void:
	_spawn_workers(null, card)


func _spawn_workers(
	runtime: MutationRuntime,
	card: CardRoot
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if workers_per_hit <= 0:
		return

	if card.deck_system_root == null:
		print("ColonyNest blocked: card.deck_system_root missing")
		return

	if runtime != null:
		runtime.trigger_visual()

	card.deck_system_root.spawn_workers_from_effect_for_card_owner(
		card,
		workers_per_hit,
		respect_hand_limit
	)
