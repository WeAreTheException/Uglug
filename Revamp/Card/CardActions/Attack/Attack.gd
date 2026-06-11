extends Node
class_name Attack

signal attack_started(context: AttackContext)
signal attack_hit(context: AttackContext)
signal attack_finished(context: AttackContext)

@export var animation_runner: AttackAnimationRunner
@export var target_resolver: AttackTargetResolver
@export var attack_sequencer: AttackSequencer
@export var impact_handler: AttackImpactHandler

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_A

var card: CardRoot = null
var slots_root: SlotsRoot = null

var is_hovered := false
var is_attacking := false

var active_context: AttackContext = null
var impact_handled := false


func setup(source_card: CardRoot, source_slots_root: SlotsRoot) -> void:
	card = source_card
	slots_root = source_slots_root

	if card == null:
		print("ATTACK SETUP BLOCKED: card null")
		return

	print("ATTACK SETUP: ", card.card_name)

	if animation_runner != null:
		if not animation_runner.impact_reached.is_connected(_on_impact_reached):
			animation_runner.impact_reached.connect(_on_impact_reached)

	if impact_handler != null:
		if not impact_handler.attack_hit.is_connected(_on_attack_hit):
			impact_handler.attack_hit.connect(_on_attack_hit)

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
			print("ATTACK DEBUG KEY PRESSED")
			perform_attack()


func perform_attack() -> void:
	print("ATTACK CALLED")

	if is_attacking:
		print("ATTACK BLOCKED: already attacking")
		return

	if not _can_attack():
		return

	var attacker_slot := card.get_current_slot()

	if attacker_slot == null:
		print("ATTACK BLOCKED: attacker slot missing")
		return

	var attacker_owner := slots_root.get_owner_of_slot(attacker_slot)
	var left_to_right := _get_left_to_right(attacker_owner)
	var steps := attack_sequencer.build_steps_with_order(card, left_to_right)

	print("ATTACK OWNER: ", attacker_owner)
	print("ATTACK LEFT TO RIGHT: ", left_to_right)
	print("ATTACK STEPS COUNT: ", steps.size())

	for debug_step in steps:
		if debug_step == null:
			print("ATTACK STEP: NULL")
		else:
			print("ATTACK STEP: ", debug_step.direction)

	if steps.is_empty():
		print("ATTACK BLOCKED: no steps")
		return

	is_attacking = true

	for step in steps:
		if step == null:
			print("ATTACK STEP SKIPPED: null")
			continue

		var context := _build_context(step, attacker_slot, attacker_owner)

		target_resolver.resolve_target(slots_root, context)

		if context.target_slot == null:
			print("ATTACK STEP SKIPPED: target slot null for ", step.direction)
			continue

		context.target_owner = slots_root.get_owner_of_slot(context.target_slot)

		print("ATTACK PLAYING STEP: ", step.direction)
		print("TARGET SLOT INDEX: ", context.target_slot.slot_index)

		active_context = context
		impact_handled = false

		attack_started.emit(context)

		await animation_runner.play_attack(context)

		if not impact_handled:
			print("ATTACK FALLBACK IMPACT")
			await _handle_impact(context)

		attack_finished.emit(context)

		active_context = null
		impact_handled = false

	is_attacking = false
	print("ATTACK COMPLETE")


func _can_attack() -> bool:
	if card == null:
		print("ATTACK BLOCKED: card null")
		return false

	if slots_root == null:
		print("ATTACK BLOCKED: slots_root missing")
		return false

	if attack_sequencer == null:
		print("ATTACK BLOCKED: attack_sequencer missing")
		return false

	if target_resolver == null:
		print("ATTACK BLOCKED: target_resolver missing")
		return false

	if animation_runner == null:
		print("ATTACK BLOCKED: animation_runner missing")
		return false

	if impact_handler == null:
		print("ATTACK BLOCKED: impact_handler missing")
		return false

	return true


func _get_left_to_right(slot_owner: SlotRow.SlotOwner) -> bool:
	if slots_root == null:
		return true

	if slots_root.attack_order_handler == null:
		print("ATTACK ORDER HANDLER MISSING: defaulting left_to_right true")
		return true

	return slots_root.attack_order_handler.get_left_to_right(slot_owner)


func _build_context(
	step: AttackStep,
	attacker_slot: Slot,
	attacker_owner: SlotRow.SlotOwner
) -> AttackContext:
	var context := AttackContext.new()

	context.setup_from_step(
		card,
		attacker_slot,
		attacker_owner,
		step,
		slots_root.attack_animation_layer
	)

	return context


func _on_impact_reached() -> void:
	print("ATTACK IMPACT REACHED")

	if active_context == null:
		print("IMPACT BLOCKED: active_context null")
		return

	if impact_handled:
		print("IMPACT BLOCKED: already handled")
		return

	impact_handled = true
	_handle_impact(active_context)


func _handle_impact(context: AttackContext) -> void:
	print("HANDLE IMPACT")
	await impact_handler.handle_impact(context, card)


func _on_attack_hit(context: AttackContext) -> void:
	print("ATTACK HIT SIGNAL")
	attack_hit.emit(context)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
