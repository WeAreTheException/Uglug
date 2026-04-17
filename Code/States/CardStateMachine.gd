extends Node
class_name CardStateMachine

enum MainState {
	ATTACK,
	HURT,
	DEATH,
	WAIT
}

enum PowerState {
	BASE,
	EMPOWERED
}

@export var attack_feedback: AttackFeedbackHandler
@export var hurt_feedback: HurtFeedbackHandler
@export var death_feedback: DeathFeedbackHandler

var current_main_state: MainState = MainState.WAIT
var current_power_state: PowerState = PowerState.BASE

var card: Card = null
var busy: bool = false

func _ready() -> void:
	card = get_parent() as Card

	if attack_feedback == null:
		attack_feedback = get_node_or_null("../AttackFeedbackHandler")
	if hurt_feedback == null:
		hurt_feedback = get_node_or_null("../HurtFeedbackHandler")
	if death_feedback == null:
		death_feedback = get_node_or_null("../DeathFeedbackHandler")

func _unhandled_input(event: InputEvent) -> void:
	if card == null:
		return
	if busy:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_A, KEY_H, KEY_D:
				if card.current_slot == null:
					print("card must be in a slot")
					return

				if not card.is_hovered:
					return

				match event.keycode:
					KEY_A:
						await play_attack_state()
					KEY_H:
						await play_hurt_state()
					KEY_D:
						await play_death_state()

func set_main_state(new_state: MainState) -> void:
	current_main_state = new_state
	print(MainState.keys()[current_main_state].to_lower())

func play_attack_state() -> void:
	if card == null:
		return
	if busy:
		return

	if card.current_attack <= 0:
		print(card.card_name, " has 0 attack, skipping attack")
		return

	busy = true
	set_main_state(MainState.ATTACK)

	if card.current_slot == null:
		print("attack blocked")
		set_main_state(MainState.WAIT)
		busy = false
		return

	var opposing_slot = card.current_slot.opposing_slot
	var opposing_card: Card = null

	if opposing_slot != null:
		opposing_card = opposing_slot.current_card

	var final_target: Card = opposing_card

	if card.quirk != null:
		final_target = card.quirk.get_attack_target(card, opposing_card)

	if attack_feedback != null:
		await attack_feedback.play_attack(final_target)

	if final_target != null:
		if final_target.has_method("take_damage"):
			var damage := card.current_attack

			if card.quirk != null:
				damage = card.quirk.modify_damage(card, final_target, damage)

			print(card.card_name, " -> ", final_target.card_name, " (", damage, " dmg)")
			final_target.take_damage(damage, card)
		else:
			print("target card has no take_damage")
	else:
		var direct_damage := card.current_attack

		if card.card_owner == Card.Owner.PLAYER:
			print(card.card_name, " -> opponent (", direct_damage, " dmg)")
		else:
			print(card.card_name, " -> player (", direct_damage, " dmg)")

		if card.battle_scale != null:
			card.battle_scale.add_direct_damage(direct_damage, card.card_owner)

	set_main_state(MainState.WAIT)
	busy = false

func play_hurt_state() -> void:
	if card == null:
		return
	if busy:
		return

	busy = true
	set_main_state(MainState.HURT)

	if hurt_feedback != null:
		await hurt_feedback.play_hurt()

	set_main_state(MainState.WAIT)
	busy = false

func play_death_state() -> void:
	if card == null:
		return
	if busy:
		return

	busy = true
	set_main_state(MainState.DEATH)

	if death_feedback != null:
		await death_feedback.play_death()

	if is_instance_valid(card):
		card.kill()

	busy = false

func set_power_state(new_state: PowerState) -> void:
	if current_power_state == new_state:
		return

	current_power_state = new_state

func is_in_main_state(state: MainState) -> bool:
	return current_main_state == state

func is_in_power_state(state: PowerState) -> bool:
	return current_power_state == state
