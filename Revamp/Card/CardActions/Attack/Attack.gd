extends Node
class_name Attack

signal attack_started(context: AttackContext)
signal attack_hit(context: AttackContext)
signal attack_finished(context: AttackContext)

@export var animation_runner: AttackAnimationRunner
@export var target_resolver: AttackTargetResolver
@export var attack_sequencer: AttackSequencer
@export var exchange_runner: AttackExchangeRunner

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_A

var card: CardRoot = null
var slots_root: SlotsRoot = null

var is_hovered := false
var is_attacking := false


func setup(source_card: CardRoot, source_slots_root: SlotsRoot) -> void:
	card = source_card
	slots_root = source_slots_root

	if card == null:
		return

	if exchange_runner != null:
		if slots_root != null:
			exchange_runner.setup(slots_root.direct_damage_router)

		if not exchange_runner.exchange_hit.is_connected(_on_exchange_hit):
			exchange_runner.exchange_hit.connect(_on_exchange_hit)

	if not card.hovered.is_connected(_on_card_hovered):
		card.hovered.connect(_on_card_hovered)

	if not card.unhovered.is_connected(_on_card_unhovered):
		card.unhovered.connect(_on_card_unhovered)


func _input(event: InputEvent) -> void:
	if not enable_debug_key:
		return

	if not is_hovered:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_key:
			perform_attack()


func perform_attack() -> void:
	if is_attacking:
		return

	if not _can_attack():
		return

	var starting_slot: Slot = card.get_current_slot()

	if starting_slot == null:
		return

	var attacker_owner: SlotRow.SlotOwner = slots_root.get_owner_of_slot(starting_slot)
	var left_to_right: bool = _get_left_to_right(attacker_owner)
	var steps: Array[AttackStep] = attack_sequencer.build_steps_with_order(card, left_to_right)

	if steps.is_empty():
		return

	is_attacking = true

	var sequence_started := false
	var sequence_context: AttackContext = null

	for step in steps:
		if step == null:
			continue

		if not _can_continue_attack_sequence():
			break

		var context: AttackContext = _build_context_for_step(step, attacker_owner)

		if context == null:
			break

		target_resolver.resolve_target(slots_root, context)

		if context.target_slot == null:
			continue

		context.target_owner = slots_root.get_owner_of_slot(context.target_slot)

		if not sequence_started:
			_notify_attack_sequence_started(context)
			sequence_started = true
			sequence_context = context

		attack_started.emit(context)

		await animation_runner.play_to_impact(context)

		var exchange: AttackExchangeContext = exchange_runner.build_exchange(context)

		if _can_play_return_animation():
			await animation_runner.play_return()

		await exchange_runner.resolve_exchange(exchange)

		attack_finished.emit(context)

		if not _can_continue_attack_sequence():
			break

	if sequence_started:
		_notify_attack_sequence_finished(sequence_context)

	is_attacking = false


func _can_attack() -> bool:
	if card == null:
		return false

	if slots_root == null:
		print("attack blocked: slots_root missing")
		return false

	if attack_sequencer == null:
		print("attack blocked: attack_sequencer missing")
		return false

	if target_resolver == null:
		print("attack blocked: target_resolver missing")
		return false

	if animation_runner == null:
		print("attack blocked: animation_runner missing")
		return false

	if exchange_runner == null:
		print("attack blocked: exchange_runner missing")
		return false

	return true


func _can_continue_attack_sequence() -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	if card.die != null and card.die.is_unavailable_for_combat():
		return false

	if card.stats != null and card.stats.is_dead():
		return false

	if card.get_current_slot() == null:
		return false

	return true


func _can_play_return_animation() -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	if animation_runner == null:
		return false

	return true


func _get_left_to_right(slot_owner: SlotRow.SlotOwner) -> bool:
	if slots_root == null:
		return true

	if slots_root.attack_order_handler == null:
		return true

	return slots_root.attack_order_handler.get_left_to_right(slot_owner)


func _build_context_for_step(
	step: AttackStep,
	attacker_owner: SlotRow.SlotOwner
) -> AttackContext:
	var attacker_slot: Slot = card.get_current_slot()

	if attacker_slot == null:
		return null

	var context := AttackContext.new()

	context.setup_from_step(
		card,
		attacker_slot,
		attacker_owner,
		step,
		slots_root.attack_animation_layer
	)

	return context


func _notify_attack_sequence_started(context: AttackContext) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.mutations == null:
		return

	card.mutations.notify_attack_sequence_started(context)


func _notify_attack_sequence_finished(context: AttackContext) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.mutations == null:
		return

	card.mutations.notify_attack_sequence_finished(context)


func _on_exchange_hit(exchange: AttackExchangeContext) -> void:
	if exchange == null:
		return

	if exchange.attack_context == null:
		return

	attack_hit.emit(exchange.attack_context)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
