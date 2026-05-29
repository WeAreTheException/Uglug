extends Node
class_name Attack

@export var atk_forward: AttackAnimation
@export var atk_left_close: AttackAnimation
@export var atk_right_close: AttackAnimation
@export var atk_left_far: AttackAnimation
@export var atk_right_far: AttackAnimation

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

	var attacker_slot := card.get_current_slot()

	if attacker_slot == null:
		print("attack blocked: card is not in a slot")
		return

	var target_slot := slots_root.get_opposing_slot(attacker_slot)

	if target_slot == null:
		print("attack blocked: no target slot")
		return

	var animation := _get_animation_for_target(attacker_slot, target_slot)

	if animation == null:
		print("attack blocked: no attack animation assigned")
		return

	is_attacking = true
	await animation.play()
	is_attacking = false


func _get_animation_for_target(attacker_slot: Slot, target_slot: Slot) -> AttackAnimation:
	var difference := target_slot.slot_index - attacker_slot.slot_index

	match difference:
		-2:
			return atk_left_far if atk_left_far != null else atk_forward
		-1:
			return atk_left_close if atk_left_close != null else atk_forward
		0:
			return atk_forward
		1:
			return atk_right_close if atk_right_close != null else atk_forward
		2:
			return atk_right_far if atk_right_far != null else atk_forward

	return atk_forward


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
