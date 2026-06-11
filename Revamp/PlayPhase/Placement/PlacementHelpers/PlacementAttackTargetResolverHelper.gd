extends RefCounted
class_name PlacementAttackTargetResolverHelper


func resolve_target(
	board: SlotsRoot,
	card: CardRoot,
	origin_slot: Slot,
	attack_event: String
) -> Slot:
	if board == null or card == null or origin_slot == null:
		return null

	if card.attack != null and card.attack.target_resolver != null:
		var context := AttackContext.new()
		context.attacker_card = card
		context.attacker_slot = origin_slot
		context.origin_slot = origin_slot
		context.attack_event = attack_event

		card.attack.target_resolver.resolve_target(board, context)
		return context.target_slot

	return _resolve_basic_target(board, origin_slot, attack_event)


func _resolve_basic_target(
	board: SlotsRoot,
	origin_slot: Slot,
	attack_event: String
) -> Slot:
	var owner := board.get_owner_of_slot(origin_slot)
	var enemy_owner := board.get_enemy_owner(owner)

	match attack_event:
		AttackSequencer.FORWARD:
			return board.get_slot(enemy_owner, origin_slot.slot_index)

		AttackSequencer.LEFT:
			return board.get_slot(enemy_owner, origin_slot.slot_index - 1)

		AttackSequencer.RIGHT:
			return board.get_slot(enemy_owner, origin_slot.slot_index + 1)

	return null
