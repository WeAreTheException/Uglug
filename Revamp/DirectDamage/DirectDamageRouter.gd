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

	await _resolve_direct_damage(context)


func _resolve_direct_damage(context: DirectDamageContext) -> void:
	if context == null:
		return

	if context.amount <= 0:
		return

	direct_damage_requested.emit(
		context.attacker,
		context.attacker_owner,
		context.target_slot,
		context.amount
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
	if not _is_live_card(interceptor):
		_apply_score_damage(context)
		return

	var health_before: int = _get_card_health(interceptor)
	var overflow: int = max(context.amount - health_before, 0)

	context.was_intercepted = true
	context.interceptor_card = interceptor
	context.ignore_interceptor(interceptor)

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

	if overflow > 0:
		var overflow_context := DirectDamageContext.new()
		overflow_context.setup(
			context.attacker,
			context.attacker_owner,
			context.defender_owner,
			context.target_slot,
			overflow
		)
		overflow_context.copy_ignored_interceptors_from(context)

		await _resolve_direct_damage(overflow_context)


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

		if not _can_card_intercept(card, context):
			continue

		return card

	return null


func _can_card_intercept(
	card: CardRoot,
	context: DirectDamageContext
) -> bool:
	if not _is_live_card(card):
		return false

	if context.is_interceptor_ignored(card):
		return false

	if card.mutations == null:
		return false

	return card.mutations.can_intercept_direct_damage(context)


func _is_live_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	if card.stats == null:
		return true

	if card.stats.has_method("is_dead"):
		return not card.stats.is_dead()

	return true


func _get_card_health(card: CardRoot) -> int:
	if card == null:
		return 0

	if card.stats == null:
		return 0

	if card.stats.has_method("get_health"):
		return int(card.stats.get_health())

	var raw_health: Variant = card.stats.get("health")

	if raw_health is int:
		return int(raw_health)

	return 0


func _get_defender_owner(target_slot: Slot) -> SlotRow.SlotOwner:
	if slots_root == null:
		return SlotRow.SlotOwner.OPPONENT

	return slots_root.get_owner_of_slot(target_slot)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
