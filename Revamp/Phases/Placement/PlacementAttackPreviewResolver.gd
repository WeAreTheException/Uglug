extends Node
class_name PlacementAttackPreviewResolver

var controller: PlacementController = null
var preview_slots: Array[Slot] = []


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func show_preview(card: CardRoot, origin_slot: Slot) -> void:
	clear_preview()

	preview_slots = get_preview_slots(card, origin_slot)

	for slot in preview_slots:
		if slot != null:
			slot.show_attack_preview(true)


func clear_preview() -> void:
	for slot in preview_slots:
		if slot != null:
			slot.show_attack_preview(false)

	preview_slots.clear()


func get_preview_slots(card: CardRoot, origin_slot: Slot) -> Array[Slot]:
	var result: Array[Slot] = []

	if card == null:
		return result

	if origin_slot == null:
		return result

	if card.stats != null and card.stats.get_attack() <= 0:
		return result

	for attack_event in _get_attack_sequence(card):
		var target_slot := _resolve_target(card, origin_slot, attack_event)

		if target_slot != null and not result.has(target_slot):
			result.append(target_slot)

	return result


func get_current_preview_slots() -> Array[Slot]:
	return preview_slots.duplicate()


func _get_attack_sequence(card: CardRoot) -> Array[String]:
	if card.attack == null:
		return [AttackSequencer.FORWARD]

	if card.attack.attack_sequencer == null:
		return [AttackSequencer.FORWARD]

	return card.attack.attack_sequencer.build_sequence(card)


func _resolve_target(card: CardRoot, origin_slot: Slot, attack_event: String) -> Slot:
	var board := controller.get_slots_root()

	if board == null:
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
	var enemy_owner := SlotRow.SlotOwner.OPPONENT

	if owner == SlotRow.SlotOwner.OPPONENT:
		enemy_owner = SlotRow.SlotOwner.PLAYER

	match attack_event:
		AttackSequencer.FORWARD:
			return board.get_slot(enemy_owner, origin_slot.slot_index)

		AttackSequencer.LEFT:
			return board.get_slot(enemy_owner, origin_slot.slot_index - 1)

		AttackSequencer.RIGHT:
			return board.get_slot(enemy_owner, origin_slot.slot_index + 1)

	return null
