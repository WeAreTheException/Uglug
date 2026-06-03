extends Node
class_name PhaseManager

signal hand_mode_changed(mode: HandMode)

enum HandMode {
	HAND_PASSIVE,
	HAND_ACTIVE
}

@export var player_hand: PlayerHandRoot

@export var enable_debug_keys: bool = true
@export var active_key: Key = KEY_3
@export var passive_key: Key = KEY_4

var current_hand_mode: HandMode = HandMode.HAND_PASSIVE


func _ready() -> void:
	_apply_hand_mode()


func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == active_key:
			set_hand_mode(HandMode.HAND_ACTIVE)

		if event.keycode == passive_key:
			set_hand_mode(HandMode.HAND_PASSIVE)


func set_hand_mode(mode: HandMode) -> void:
	if current_hand_mode == mode:
		return

	current_hand_mode = mode

	hand_mode_changed.emit(current_hand_mode)
	_apply_hand_mode()


func _apply_hand_mode() -> void:
	if player_hand != null:
		player_hand.set_hand_mode(current_hand_mode)
