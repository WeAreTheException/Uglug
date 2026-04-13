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

	if card.current_slot == null:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_A, KEY_H, KEY_D:
					print("card must be in a slot")
		return

	if event is InputEventKey and event.pressed and not event.echo:
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

	var opposing_slot = card.current_slot.opposing_slot

	if opposing_slot != null and opposing_slot.current_card != null:
		var opposing_card = opposing_slot.current_card

		if opposing_card.has_method("take_damage"):
			print(card.card_name, " -> ", opposing_card.card_name, " (", card.current_attack, " dmg)")
			opposing_card.take_damage(card.current_attack)
		else:
			print("opposing card has no take_damage")
	else:
		print(card.card_name, " -> player (", card.current_attack, " dmg)")

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
