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

var current_main_state: MainState = MainState.WAIT
var current_power_state: PowerState = PowerState.BASE

var card: Card = null

func _ready() -> void:
	card = get_parent() as Card

func _unhandled_input(event: InputEvent) -> void:
	if card == null:
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
						set_main_state(MainState.ATTACK)
					KEY_H:
						set_main_state(MainState.HURT)
					KEY_D:
						set_main_state(MainState.DEATH)

func set_main_state(new_state: MainState) -> void:
	if current_main_state == new_state:
		return

	current_main_state = new_state
	print(MainState.keys()[current_main_state].to_lower())

	match current_main_state:
		MainState.ATTACK:
			enter_attack()
		MainState.HURT:
			enter_hurt()
		MainState.DEATH:
			enter_death()
		MainState.WAIT:
			enter_wait()

func enter_attack() -> void:
	if card == null:
		return

	if card.current_slot == null:
		print("attack blocked")
		set_main_state(MainState.WAIT)
		return

	print("slot owner: ", card.current_slot.slot_owner)
	print("card owner: ", card.card_owner)

	var opposing_slot = card.current_slot.opposing_slot
	var opposing_card: Card = null

	if opposing_slot != null:
		opposing_card = opposing_slot.current_card

	var final_target: Card = opposing_card

	if card.quirk != null:
		final_target = card.quirk.get_attack_target(card, opposing_card)

	if final_target != null:
		if final_target.has_method("take_damage"):
			var damage := card.current_attack

			if card.quirk != null:
				damage = card.quirk.modify_damage(card, final_target, damage)

			print(card.card_name, " -> ", final_target.card_name, " (", damage, " dmg)")
			final_target.take_damage(damage)
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

func enter_hurt() -> void:
	if card == null:
		return

	card.take_damage(1)

	if is_instance_valid(card) and card.current_health > 0:
		set_main_state(MainState.WAIT)

func enter_death() -> void:
	if card != null:
		card.kill()

func enter_wait() -> void:
	pass

func set_power_state(new_state: PowerState) -> void:
	if current_power_state == new_state:
		return

	current_power_state = new_state

func is_in_main_state(state: MainState) -> bool:
	return current_main_state == state

func is_in_power_state(state: PowerState) -> bool:
	return current_power_state == state
