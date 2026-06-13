extends Mutation
class_name Lifesteal

@export var health_gain_amount: int = 1
@export var gain_based_on_damage_dealt: bool = false


func on_damage_dealt(
	card: CardRoot,
	_target: CardRoot,
	damage: int
) -> void:
	_apply_lifesteal(card, damage)


func on_damage_dealt_context(
	_runtime: MutationRuntime,
	context: DamageContext
) -> void:
	if context == null:
		return

	_apply_lifesteal(
		context.source_card,
		context.actual_damage
	)


func _apply_lifesteal(card: CardRoot, damage: int) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.stats == null:
		return

	if damage <= 0:
		return

	var final_gain: int = health_gain_amount

	if gain_based_on_damage_dealt:
		final_gain = damage

	_add_health_gain(card, final_gain)


func _add_health_gain(card: CardRoot, amount: int) -> void:
	if amount <= 0:
		return

	var modifier := StatModifier.new()
	modifier.stat_name = "health"
	modifier.amount = amount
	modifier.duration_type = StatModifier.DurationType.PERMANENT
	modifier.source = self

	card.stats.add_modifier(modifier)
