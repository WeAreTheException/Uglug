extends Node
class_name Hurt

signal hurt_started(card: CardRoot, damage: int)
signal hurt_finished(card: CardRoot, damage: int)

@export var animation_runner: HurtAnimationRunner

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


func play_hurt(amount: int = 1, attacker: CardRoot = null) -> void:
	if is_playing:
		return

	if card == null:
		return

	hurt_started.emit(card, amount)

	if change_health_on_hurt and card.stats != null:
		card.stats.take_damage(amount)

	_notify_damaged_mutations(attacker, amount)

	if animation_runner == null:
		print("hurt blocked: animation_runner missing")
		return

	is_playing = true

	await animation_runner.play(card)

	if card.stats != null and card.stats.is_dead():
		if card.die != null:
			await card.die.play_die()

	is_playing = false

	hurt_finished.emit(card, amount)


func _notify_damaged_mutations(attacker: CardRoot, amount: int) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		runtime.mutation.on_damaged(
			card,
			attacker,
			amount
		)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
