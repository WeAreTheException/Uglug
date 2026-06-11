extends Resource
class_name AttackContext

var attacker_card: CardRoot = null
var attacker_slot: Slot = null
var attacker_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER

var attack_step: AttackStep = null
var attack_event: String = ""

var origin_slot: Slot = null
var target_slot: Slot = null
var target_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.OPPONENT

var attack_animation_layer: Node2D = null


func setup_from_step(
	new_attacker_card: CardRoot,
	new_attacker_slot: Slot,
	new_attacker_owner: SlotRow.SlotOwner,
	step: AttackStep,
	animation_layer: Node2D
) -> void:
	attacker_card = new_attacker_card
	attacker_slot = new_attacker_slot
	attacker_owner = new_attacker_owner

	attack_step = step
	attack_event = _get_step_direction(step)

	origin_slot = new_attacker_slot
	attack_animation_layer = animation_layer


func get_attack_direction() -> String:
	if attack_step != null:
		return _get_step_direction(attack_step)

	if attack_event != "":
		return attack_event

	return AttackStep.FORWARD


func _get_step_direction(step: AttackStep) -> String:
	if step == null:
		return AttackStep.FORWARD

	if step.direction == "":
		return AttackStep.FORWARD

	return step.direction
