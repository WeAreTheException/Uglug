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
var attack_handler: AttackHandler = null
var hurt_handler: HurtHandler = null
var die_handler: DieHandler = null

func _ready() -> void:
	card = get_parent() as Card

	attack_handler = get_node_or_null("Attack") as AttackHandler
	hurt_handler = get_node_or_null("Hurt") as HurtHandler
	die_handler = get_node_or_null("Die") as DieHandler

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
	if attack_handler == null:
		print("attack blocked: attack_handler is null")
		set_main_state(MainState.WAIT)
		return

	attack_handler.attack()
	set_main_state(MainState.WAIT)

func enter_hurt() -> void:
	if hurt_handler == null:
		print("hurt blocked: hurt_handler is null")
		set_main_state(MainState.WAIT)
		return

	hurt_handler.take_damage(1)

	if is_instance_valid(card) and card.current_health > 0:
		set_main_state(MainState.WAIT)

func enter_death() -> void:
	if die_handler == null:
		print("death blocked: die_handler is null")
		return

	die_handler.die()

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
