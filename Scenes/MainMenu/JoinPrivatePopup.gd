extends Control
class_name JoinPrivatePopup

signal enter_requested(passcode: String)
signal close_requested

@export var digit_one: Button
@export var digit_two: Button
@export var digit_three: Button
@export var enter_button: Button
@export var close_button: Button

var digits := [1, 1, 1]


func _ready() -> void:
	visible = false

	digit_one.pressed.connect(_on_digit_pressed.bind(0))
	digit_two.pressed.connect(_on_digit_pressed.bind(1))
	digit_three.pressed.connect(_on_digit_pressed.bind(2))
	enter_button.pressed.connect(_on_enter_pressed)
	close_button.pressed.connect(_on_close_pressed)

	_update_digit_text()


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _on_digit_pressed(index: int) -> void:
	digits[index] += 1

	if digits[index] > 9:
		digits[index] = 1

	_update_digit_text()


func _on_enter_pressed() -> void:
	enter_requested.emit(_get_passcode())


func _on_close_pressed() -> void:
	close()
	close_requested.emit()


func _get_passcode() -> String:
	return str(digits[0]) + str(digits[1]) + str(digits[2])


func _update_digit_text() -> void:
	digit_one.text = str(digits[0])
	digit_two.text = str(digits[1])
	digit_three.text = str(digits[2])
