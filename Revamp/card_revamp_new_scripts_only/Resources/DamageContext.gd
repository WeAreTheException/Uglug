extends Resource
class_name DamageContext

var source_card: CardRoot = null
var target_card: CardRoot = null
var source_slot: Slot = null
var target_slot: Slot = null
var attack_context: AttackContext = null
var damage_type: String = DamageTypes.COMBAT
var base_amount: int = 0
var final_amount: int = 0
var was_blocked: bool = false
var source_runtime: MutationRuntime = null
var source_type: String = StatModifierSourceTypes.BASE

func setup_combat(context: AttackContext, amount: int) -> void:
	attack_context = context
	base_amount = amount
	final_amount = amount
	damage_type = DamageTypes.COMBAT
	if context == null:
		return
	source_card = context.attacker_card
	source_slot = context.attacker_slot
	target_slot = context.target_slot
	if target_slot != null:
		target_card = target_slot.current_card
