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
		return

	if not card.is_hovered:
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
	print("Main state entered: ", MainState.keys()[current_main_state])

func set_power_state(new_state: PowerState) -> void:
	if current_power_state == new_state:
		return

	current_power_state = new_state
	print("Power state entered: ", PowerState.keys()[current_power_state])

func is_in_main_state(state: MainState) -> bool:
	return current_main_state == state

func is_in_power_state(state: PowerState) -> bool:
	return current_power_state == state
