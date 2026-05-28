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

@export var attack_handler: AttackHandler
@export var hurt_handler: HurtHandler
@export var die_handler: DieHandler

var current_main_state: MainState = MainState.WAIT
var current_power_state: PowerState = PowerState.BASE

var card: Card = null


func _ready() -> void:
	card = get_parent() as Card

	if attack_handler == null:
		attack_handler = get_node_or_null("Attack/AttackHandler") as AttackHandler

	if hurt_handler == null:
		hurt_handler = get_node_or_null("Hurt") as HurtHandler

	if die_handler == null:
		die_handler = get_node_or_null("Die") as DieHandler


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_A:
				_debug_all_cards(MainState.ATTACK)
			KEY_H:
				_debug_all_cards(MainState.HURT)
			KEY_D:
				_debug_all_cards(MainState.DEATH)


func _debug_all_cards(state: MainState) -> void:
	var cards := get_tree().get_nodes_in_group("cards")

	for found_card in cards:
		if found_card == null:
			continue

		if not found_card is Card:
			continue

		var found_state_machine := found_card.get_node_or_null("CardStateMachine") as CardStateMachine

		if found_state_machine == null:
			continue

		if found_card.current_slot == null:
			print("card must be in a slot: ", found_card.name)
			continue

		found_state_machine.set_main_state(state)


func set_main_state(new_state: MainState) -> void:
	if current_main_state == new_state:
		return

	current_main_state = new_state
	print(MainState.keys()[current_main_state].to_lower())

	match current_main_state:
		MainState.ATTACK:
			if attack_handler == null:
				print("attack blocked: attack_handler is null")
				set_main_state(MainState.WAIT)
				return

			attack_handler.enter_attack()
			set_main_state(MainState.WAIT)

		MainState.HURT:
			enter_hurt()

		MainState.DEATH:
			enter_death()

		MainState.WAIT:
			enter_wait()


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
