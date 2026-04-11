extends Node
class_name CardStateMachine

enum EStates {
	DRAWN,
	PLACED,
	ATTACK,
	HURT,
	DEATH,
}

signal on_current_state_changed(state: EStates)

@export var initial_state: EStates = EStates.DRAWN

var _current_state: EStates = EStates.DRAWN
var current_state: EStates:
	get:
		return _current_state
	set(value):
		if _current_state != value:
			_current_state = value
			on_current_state_changed.emit(value)

func _ready() -> void:
	current_state = initial_state

func change_state(new_state: EStates) -> void:
	if current_state == new_state:
		return

	current_state = new_state
