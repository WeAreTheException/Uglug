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

var ignored_interceptor_ids: Array[int] = []


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


func copy_ignored_interceptors_from(source_context: DirectDamageContext) -> void:
	if source_context == null:
		return

	ignored_interceptor_ids = source_context.ignored_interceptor_ids.duplicate()


func ignore_interceptor(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	var instance_id := card.get_instance_id()

	if ignored_interceptor_ids.has(instance_id):
		return

	ignored_interceptor_ids.append(instance_id)


func is_interceptor_ignored(card: CardRoot) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	return ignored_interceptor_ids.has(card.get_instance_id())
