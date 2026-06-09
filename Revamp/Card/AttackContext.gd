extends Resource
class_name AttackContext

var attacker_card: CardRoot = null
var attacker_slot: Slot = null
var attacker_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var attack_step: AttackStep = null
var attack_event: String = AttackEvents.FORWARD
var origin_slot: Slot = null
var target_slot: Slot = null
var target_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.OPPONENT
var attack_animation_layer: Node2D = null

func setup_step(step: AttackStep) -> void:
	attack_step = step
	if step != null:
		attack_event = step.attack_event
