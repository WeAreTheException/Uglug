extends Resource
class_name DeathContext

var dead_card: CardRoot = null
var killer_card: CardRoot = null
var death_reason: String = DeathReasons.DAMAGE
var damage_context: DamageContext = null
var should_trigger_death_mutations: bool = true
var should_free_card: bool = true
var should_play_feedback: bool = true

func setup_from_damage(card: CardRoot, context: DamageContext) -> void:
	dead_card = card
	damage_context = context
	death_reason = DeathReasons.DAMAGE
	if context != null:
		killer_card = context.source_card
