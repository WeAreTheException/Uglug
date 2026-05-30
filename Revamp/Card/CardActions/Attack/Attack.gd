extends Node
class_name Attack

@export var animation_runner: AttackAnimationRunner
@export var target_resolver: AttackTargetResolver

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
		print("attack blocked: card missing")
		return

	if slots_root == null:
		print("attack blocked: slots_root missing")
		return

	if animation_runner == null:
		print("attack blocked: animation runner missing")
		return

	if target_resolver == null:
		print("attack blocked: target resolver missing")
		return

	var attacker_slot := card.get_current_slot()

	if attacker_slot == null:
		print("attack blocked: card is not in a slot")
		return

	var target_slots := target_resolver.get_target_slots(card, slots_root)

	if target_slots.is_empty():
		print("attack skipped: no valid target slots")
		return

	is_attacking = true

	var attack_count := _get_attack_count()

	for attack_index in range(attack_count):
		for target_slot in target_slots:
			if target_slot == null:
				continue

			await animation_runner.play_attack(attacker_slot, target_slot)

	is_attacking = false


func _get_attack_count() -> int:
	if _has_mutation_named("Divergent Fist"):
		return 2

	return 1


func _has_mutation_named(target_name: String) -> bool:
	if card == null:
		return false

	if card.mutations == null:
		return false

	for mutation in card.mutations.get_active_mutations():
		if mutation == null:
			continue

		if "mutation_name" in mutation and mutation.mutation_name == target_name:
			return true

	return false


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
