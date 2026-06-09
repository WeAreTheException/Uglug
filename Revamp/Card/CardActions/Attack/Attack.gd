extends Node
class_name Attack

signal attack_started(context: AttackContext)
signal attack_hit(context: AttackContext)
signal attack_finished(context: AttackContext)

@export var target_resolver: AttackTargetResolver
@export var attack_sequencer: AttackSequencer
@export var impact_handler: AttackImpactHandler

var card: CardRoot = null
var slots_root: SlotsRoot = null
var is_attacking := false

func setup(source_card: CardRoot, source_slots_root: SlotsRoot) -> void:
	card = source_card
	slots_root = source_slots_root
	if impact_handler != null:
		impact_handler.setup(card)
		if not impact_handler.attack_hit.is_connected(_on_attack_hit):
			impact_handler.attack_hit.connect(_on_attack_hit)

func perform_attack() -> void:
	if not _can_attack():
		return
	var attacker_slot := card.get_current_slot()
	var steps := attack_sequencer.build_steps(card)
	if steps.is_empty():
		return
	is_attacking = true
	for step in steps:
		if not is_instance_valid(card):
			break
		var context := _make_context(attacker_slot, step)
		target_resolver.resolve_target(slots_root, context)
		if context.target_slot == null:
			continue
		context.target_owner = slots_root.get_owner_of_slot(context.target_slot)
		attack_started.emit(context)
		card.attack_started.emit(context)
		if card.feedback_root != null:
			await card.feedback_root.play_attack(context)
		await impact_handler.handle_impact(context)
		attack_finished.emit(context)
		card.attack_finished.emit(context)
	is_attacking = false

func _can_attack() -> bool:
	if is_attacking or card == null or slots_root == null:
		return false
	if attack_sequencer == null or target_resolver == null:
		return false
	if impact_handler == null:
		return false
	return card.get_current_slot() != null

func _make_context(slot: Slot, step: AttackStep) -> AttackContext:
	var context := AttackContext.new()
	context.attacker_card = card
	context.attacker_slot = slot
	context.attacker_owner = slots_root.get_owner_of_slot(slot)
	context.attack_animation_layer = slots_root.attack_animation_layer
	context.origin_slot = slot
	context.setup_step(step)
	return context

func _on_attack_hit(context: AttackContext) -> void:
	attack_hit.emit(context)
	if card != null:
		card.attack_hit.emit(context)
