extends Node
class_name TuggaHandler

signal scale_changed(value: int)

@export var max_value: int = 5

var current_value: int = 0

func _ready() -> void:
	scale_changed.emit(current_value)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_EQUAL, KEY_KP_ADD:
				add_to_player_one(1)

			KEY_MINUS, KEY_KP_SUBTRACT:
				add_to_player_two(1)

func add_to_player_one(amount: int) -> void:
	current_value += amount
	current_value = clamp(current_value, -max_value, max_value)

	print("tugga: ", current_value)

	scale_changed.emit(current_value)

func add_to_player_two(amount: int) -> void:
	current_value -= amount
	current_value = clamp(current_value, -max_value, max_value)

	print("tugga: ", current_value)

	scale_changed.emit(current_value)
