extends Node
class_name Attack

@export var animation_runner: AttackAnimationRunner
@export var target_resolver: AttackTargetResolver
@export var attack_sequencer: AttackSequencer

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
			perform_debug_attack()


func perform_debug_attack() -> void:
	if is_attacking:
		return

	if card == null:
		return

	if slots_root == null:
		print("attack blocked: slots_root missing")
		return

	if attack_sequencer == null:
		print("attack blocked: attack_sequencer missing")
		return

	if target_resolver == null:
		print("attack blocked: target_resolver missing")
		return

	if animation_runner == null:
		print("attack blocked: animation_runner missing")
		return

	var attacker_slot := card.get_current_slot()

	if attacker_slot == null:
		print("attack blocked: attacker slot missing")
		return

	var sequence := attack_sequencer.build_sequence(card)

	if sequence.is_empty():
		return

	is_attacking = true

	for attack_event in sequence:
		var context := AttackContext.new()

		context.attacker_card = card
		context.attacker_slot = attacker_slot

		context.attack_event = attack_event

		# Later Distant can override this.
		context.origin_slot = attacker_slot

		target_resolver.resolve_target(
			slots_root,
			context
		)

		if context.target_slot == null:
			continue

		await animation_runner.play_attack(
			context.attacker_slot,
			context.target_slot
		)

	is_attacking = false


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
