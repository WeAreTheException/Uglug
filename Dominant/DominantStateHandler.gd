extends Node
class_name DominantStateHandler

signal state_changed(new_state: String)

enum DominantState {
	DISABLED,
	ACTIVE,
	INACTIVE
}

var current_state: DominantState = DominantState.DISABLED

func _ready() -> void:
	set_state(DominantState.DISABLED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_0:
				set_state(DominantState.DISABLED)
			KEY_9:
				set_state(DominantState.ACTIVE)
			KEY_8:
				set_state(DominantState.INACTIVE)

func set_state(new_state: DominantState) -> void:
	current_state = new_state

	var state_name := get_state_name()
	print("DOMINANT STATE CHANGED TO: ", state_name)

	state_changed.emit(state_name)

func get_state_name() -> String:
	match current_state:
		DominantState.DISABLED:
			return "Disabled"
		DominantState.ACTIVE:
			return "Active"
		DominantState.INACTIVE:
			return "Inactive"

	return "Disabled"
