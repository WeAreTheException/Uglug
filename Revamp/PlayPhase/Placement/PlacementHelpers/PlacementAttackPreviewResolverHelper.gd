extends RefCounted
class_name PlacementAttackPreviewResolverHelper

var sequence_resolver := PlacementAttackSequenceResolverHelper.new()
var target_resolver := PlacementAttackTargetResolverHelper.new()


func get_preview_slots(
	board: SlotsRoot,
	card: CardRoot,
	origin_slot: Slot
) -> Array[Slot]:
	var result: Array[Slot] = []

	if card == null or origin_slot == null:
		return result

	if card.stats != null and card.stats.get_attack() <= 0:
		return result

	for attack_event in sequence_resolver.get_attack_sequence(card):
		var target_slot := target_resolver.resolve_target(board, card, origin_slot, attack_event)

		if target_slot != null and not result.has(target_slot):
			result.append(target_slot)

	return result
