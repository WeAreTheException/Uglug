extends Node
class_name MainMenuStateManager

signal state_changed(new_state: int)

enum MenuState {
	CONNECTING,
	BROWSING,
	CREATING_LOBBY,
	HOSTING_LOBBY,
	JOINING_LOBBY,
	TRANSITIONING_TO_GAME
}

var current_state: int = MenuState.CONNECTING


func set_state(new_state: int) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(current_state)


func is_hosting() -> bool:
	return current_state == MenuState.HOSTING_LOBBY
