extends Node
class_name Hurt

signal hurt_started(card: CardRoot, damage: int)
signal hurt_finished(card: CardRoot, damage: int)

@export var animation_runner: HurtAnimationRunner
@export var feedback_handler: HurtFeedbackHandler

@export var change_health_on_hurt: bool = true
@export var default_damage_amount: int = 1

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_H

var card: CardRoot = null
var is_hovered := false
var is_playing := false


func setup(source_card: CardRoot) -> void:
	card = source_card

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
			play_hurt(default_damage_amount, null)


func play_hurt(
	amount: int = 1,
	attacker: CardRoot = null,
	trigger_damaged_mutations: bool = true
) -> int:
	var context := DamageContext.new()
	context.setup(attacker, card, amount)
	context.can_trigger_damaged = trigger_damaged_mutations
	context.can_trigger_damage_dealt = true

	return await receive_damage(context)


func receive_damage(context: DamageContext) -> int:
	if is_playing:
		return 0

	if card == null:
		return 0

	if context == null:
		return 0

	context.target_card = card
	context.target_slot = card.get_current_slot()

	if context.source_card != null:
		context.source_slot = context.source_card.get_current_slot()

	_apply_incoming_damage_modifiers(context)

	if context.final_damage <= 0:
		return 0

	hurt_started.emit(card, context.final_damage)

	if feedback_handler != null:
		feedback_handler.play(card)

	if change_health_on_hurt and card.stats != null:
		card.stats.take_damage(context.final_damage)
		context.actual_damage = context.final_damage

	_notify_damaged_mutations(context)

	if animation_runner == null:
		print("hurt blocked: animation_runner missing")
		return context.actual_damage

	is_playing = true

	await animation_runner.play(card)

	if card.stats != null and card.stats.is_dead():
		if card.die != null:
			await card.die.play_die()

	is_playing = false

	hurt_finished.emit(card, context.actual_damage)

	return context.actual_damage


func _apply_incoming_damage_modifiers(context: DamageContext) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	var damage := card.mutations.modify_incoming_damage(
		context.source_card,
		context.final_damage
	)

	context.set_final_damage(damage)


func _notify_damaged_mutations(context: DamageContext) -> void:
	if not context.can_trigger_damaged:
		return

	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_damaged(
		context.source_card,
		context.actual_damage
	)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
