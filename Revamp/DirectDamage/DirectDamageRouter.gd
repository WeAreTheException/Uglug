extends Node
class_name DirectDamageRouter

signal direct_damage_requested(
	attacker: CardRoot,
	attacker_owner: SlotRow.SlotOwner,
	target_slot: Slot,
	amount: int
)

signal direct_damage_intercepted(
	interceptor_card: CardRoot,
	amount: int
)

signal direct_damage_applied(
	attacker_owner: SlotRow.SlotOwner,
	amount: int,
	score: int
)

@export var score_state: MatchScoreState
@export var slots_root: SlotsRoot
@export var print_debug: bool = true


func request_direct_damage(
	attacker: CardRoot,
	attacker_owner: SlotRow.SlotOwner,
	target_slot: Slot,
	amount: int
) -> void:
	if attacker == null:
		return

	if target_slot == null:
		return

	if amount <= 0:
		return

	var defender_owner := _get_defender_owner(target_slot)

	var context := DirectDamageContext.new()
	context.setup(
		attacker,
		attacker_owner,
		defender_owner,
		target_slot,
		amount
	)

	direct_damage_requested.emit(
		attacker,
		attacker_owner,
		target_slot,
		amount
	)

	var interceptor := _find_direct_damage_interceptor(context)

	if interceptor != null:
		await _apply_interception(context, interceptor)
		return

	_apply_score_damage(context)


func _apply_interception(
	context: DirectDamageContext,
	interceptor: CardRoot
) -> void:
	context.was_intercepted = true
	context.interceptor_card = interceptor

	if print_debug:
		print(
			"DIRECT DAMAGE INTERCEPTED: ",
			interceptor.name,
			" amount ",
			context.amount
		)

	if interceptor.mutations != null:
		interceptor.mutations.notify_direct_damage_intercepted(context)

	if interceptor.hurt != null:
		context.actual_damage_to_interceptor = await interceptor.hurt.play_hurt(
			context.amount,
			context.attacker
		)

	if context.attacker != null and context.attacker.mutations != null:
		context.attacker.mutations.notify_damage_dealt(
			interceptor,
			context.actual_damage_to_interceptor
		)

	direct_damage_intercepted.emit(interceptor, context.amount)


func _apply_score_damage(context: DirectDamageContext) -> void:
	if print_debug:
		print(
			"DIRECT DAMAGE REQUESTED: ",
			_get_owner_name(context.attacker_owner),
			" amount ",
			context.amount
		)

	if slots_root != null:
		slots_root.show_direct_damage_feedback(context.target_slot)

	if score_state == null:
		return

	score_state.apply_direct_damage(
		context.attacker_owner,
		context.amount
	)

	direct_damage_applied.emit(
		context.attacker_owner,
		context.amount,
		score_state.score
	)


func _find_direct_damage_interceptor(
	context: DirectDamageContext
) -> CardRoot:
	if slots_root == null:
		return null

	var slots := slots_root.get_slots_for_owner(context.defender_owner)
	var left_to_right := true

	if slots_root.attack_order_handler != null:
		left_to_right = slots_root.attack_order_handler.get_left_to_right(
			context.defender_owner
		)

	if not left_to_right:
		slots.reverse()

	for slot in slots:
		if slot == null:
			continue

		var card := slot.current_card

		if card == null:
			continue

		if card.mutations == null:
			continue

		if card.mutations.can_intercept_direct_damage(context):
			return card

	return null


func _get_defender_owner(target_slot: Slot) -> SlotRow.SlotOwner:
	if slots_root == null:
		return SlotRow.SlotOwner.OPPONENT

	return slots_root.get_owner_of_slot(target_slot)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
