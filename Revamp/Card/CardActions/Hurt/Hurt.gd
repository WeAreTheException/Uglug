extends Node
class_name Hurt

signal hurt_started(card: CardRoot, damage: int)
signal hurt_finished(card: CardRoot, damage: int)
signal damage_applied(context: DamageContext)

@export var animation_runner: HurtAnimationRunner
@export var feedback_handler: HurtFeedbackHandler

@export var change_health_on_hurt: bool = true
@export var resolve_death_on_hurt_finish: bool = true
@export var play_zero_damage_feedback: bool = true
@export var damage_apply_delay: float = 0.08
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

	is_playing = true

	_prepare_context(context)
	_apply_incoming_damage_modifiers(context)

	if context.final_damage <= 0 and not play_zero_damage_feedback:
		is_playing = false
		return 0

	hurt_started.emit(card, context.final_damage)

	if feedback_handler != null:
		feedback_handler.play(card)

	if damage_apply_delay > 0.0:
		await get_tree().create_timer(damage_apply_delay).timeout

	_apply_damage(context)
	damage_applied.emit(context)

	if animation_runner != null:
		await animation_runner.play(card)
	else:
		print("hurt blocked: animation_runner missing")

	if resolve_death_on_hurt_finish:
		await _resolve_death_if_needed()

	is_playing = false
	hurt_finished.emit(card, context.actual_damage)

	return context.actual_damage


func _prepare_context(context: DamageContext) -> void:
	context.target_card = card
	context.target_slot = card.get_current_slot()

	if context.source_card != null:
		context.source_slot = context.source_card.get_current_slot()


func _apply_damage(context: DamageContext) -> void:
	if not change_health_on_hurt:
		context.actual_damage = 0
		return

	if card == null:
		context.actual_damage = 0
		return

	if card.stats == null:
		context.actual_damage = 0
		return

	if context.final_damage <= 0:
		context.actual_damage = 0
		return

	var health_before: int = card.stats.get_health()

	card.stats.take_damage(context.final_damage)

	var health_after: int = card.stats.get_health()
	context.actual_damage = max(health_before - health_after, 0)

	if context.actual_damage > 0:
		_notify_damaged_mutations(context)


func _resolve_death_if_needed() -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.stats == null:
		return

	if not card.stats.is_dead():
		return

	if card.die == null:
		return

	await card.die.play_die()


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
