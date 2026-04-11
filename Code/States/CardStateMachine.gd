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

func set_main_state(new_state: MainState) -> void:
	if current_main_state == new_state:
		return

	current_main_state = new_state

func set_power_state(new_state: PowerState) -> void:
	if current_power_state == new_state:
		return

	current_power_state = new_state

func is_in_main_state(state: MainState) -> bool:
	return current_main_state == state

func is_in_power_state(state: PowerState) -> bool:
	return current_power_state == state
