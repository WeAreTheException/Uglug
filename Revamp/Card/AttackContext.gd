extends Resource
class_name AttackContext

var attacker_card: CardRoot = null
var attacker_slot: Slot = null
var attacker_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER

var attack_event: String = ""

var origin_slot: Slot = null
var target_slot: Slot = null
var target_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.OPPONENT
