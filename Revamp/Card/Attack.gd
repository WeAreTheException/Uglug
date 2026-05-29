extends Node
class_name Attack

@export var animation_runner: AttackAnimationRunner

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
		if event.keycode == KEY_A:
			perform_debug_attack()

		if event.keycode == KEY_S:
			await _debug_all_attack_variations()


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

	var attacker_slot := card.get_current_slot()

	if attacker_slot == null:
		print("attack blocked: card is not in a slot")
		return

	var target_slot := slots_root.get_opposing_slot(attacker_slot)

	if target_slot == null:
		print("attack blocked: no target slot")
		return

	is_attacking = true
	await animation_runner.play_attack(attacker_slot, target_slot)
	is_attacking = false


func _debug_all_attack_variations() -> void:
	if animation_runner == null:
		return

	print("FORWARD")
	await animation_runner.debug_play_difference(0)

	print("RIGHT CLOSE")
	await animation_runner.debug_play_difference(1)

	print("RIGHT FAR")
	await animation_runner.debug_play_difference(2)

	print("RIGHT FURTHEST")
	await animation_runner.debug_play_difference(3)

	print("LEFT CLOSE")
	await animation_runner.debug_play_difference(-1)

	print("LEFT FAR")
	await animation_runner.debug_play_difference(-2)

	print("LEFT FURTHEST")
	await animation_runner.debug_play_difference(-3)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
