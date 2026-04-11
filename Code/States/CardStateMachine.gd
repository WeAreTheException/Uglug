extends Node
class_name CardStateMachine

enum EMainStates {
	DRAWN,
	PLACED,
	ATTACK,
	HURT,
	DEATH,
}

enum EPowerStates {
	BASE,
	EMPOWERED,
}

signal on_main_state_changed(state: EMainStates)
signal on_power_state_changed(state: EPowerStates)

@export var initial_main_state: EMainStates = EMainStates.DRAWN
@export var initial_power_state: EPowerStates = EPowerStates.BASE

var _current_main_state: EMainStates = EMainStates.DRAWN
var current_main_state: EMainStates:
	get:
		return _current_main_state
	set(value):
		if _current_main_state != value:
			_current_main_state = value
			on_main_state_changed.emit(value)

var _current_power_state: EPowerStates = EPowerStates.BASE
var current_power_state: EPowerStates:
	get:
		return _current_power_state
	set(value):
		if _current_power_state != value:
			_current_power_state = value
			on_power_state_changed.emit(value)

func _ready() -> void:
	current_main_state = initial_main_state
	current_power_state = initial_power_state

func change_main_state(new_state: EMainStates) -> void:
	if current_main_state == new_state:
		return

	current_main_state = new_state

func change_power_state(new_state: EPowerStates) -> void:
	if current_power_state == new_state:
		return

	current_power_state = new_state
