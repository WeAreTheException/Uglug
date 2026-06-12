extends Node
class_name MainMenuButtonState

signal host_pressed
signal join_random_pressed

@export var host_button: Button
@export var join_random_button: Button
@export var state_manager: MainMenuStateManager


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_random_button.pressed.connect(_on_join_random_pressed)

	state_manager.state_changed.connect(_on_state_changed)
	_on_state_changed(state_manager.current_state)


func _on_host_pressed() -> void:
	host_pressed.emit()


func _on_join_random_pressed() -> void:
	join_random_pressed.emit()


func _on_state_changed(state: int) -> void:
	match state:
		MainMenuStateManager.MenuState.CONNECTING:
			_set_buttons("Host", true, true, true)

		MainMenuStateManager.MenuState.BROWSING:
			_set_buttons("Host", false, true, false)

		MainMenuStateManager.MenuState.CREATING_LOBBY:
			_set_buttons("Host", true, true, true)

		MainMenuStateManager.MenuState.HOSTING_LOBBY:
			_set_buttons("Leave Lobby", false, false, true)

		MainMenuStateManager.MenuState.JOINING_LOBBY:
			_set_buttons("Host", true, true, true)

		MainMenuStateManager.MenuState.TRANSITIONING_TO_GAME:
			_set_buttons("Host", true, true, true)


func _set_buttons(
	host_text: String,
	host_disabled: bool,
	join_visible: bool,
	join_disabled: bool
) -> void:
	host_button.text = host_text
	host_button.disabled = host_disabled
	join_random_button.visible = join_visible
	join_random_button.disabled = join_disabled
