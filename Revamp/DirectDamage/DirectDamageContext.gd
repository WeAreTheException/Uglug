extends RefCounted
class_name DirectDamageContext

var attacker: CardRoot = null
var attacker_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var defender_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.OPPONENT
var target_slot: Slot = null
var amount: int = 1

var was_intercepted: bool = false
var interceptor_card: CardRoot = null
var actual_damage_to_interceptor: int = 0


func setup(
	source_attacker: CardRoot,
	source_attacker_owner: SlotRow.SlotOwner,
	source_defender_owner: SlotRow.SlotOwner,
	source_target_slot: Slot,
	source_amount: int
) -> void:
	attacker = source_attacker
	attacker_owner = source_attacker_owner
	defender_owner = source_defender_owner
	target_slot = source_target_slot
	amount = source_amount
