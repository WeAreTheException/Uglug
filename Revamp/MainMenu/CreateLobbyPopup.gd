extends Control
class_name CreateLobbyPopup

signal create_requested(is_private: bool, passcode: String)
signal close_requested

@export var private_toggle: CheckBox
@export var passcode_root: Control
@export var digit_one: Button
@export var digit_two: Button
@export var digit_three: Button
@export var create_button: Button
@export var close_button: Button

var digits := [0, 0, 0]


func _ready() -> void:
	visible = false

	private_toggle.toggled.connect(_on_private_toggled)
	digit_one.pressed.connect(_on_digit_pressed.bind(0))
	digit_two.pressed.connect(_on_digit_pressed.bind(1))
	digit_three.pressed.connect(_on_digit_pressed.bind(2))
	create_button.pressed.connect(_on_create_pressed)
	close_button.pressed.connect(_on_close_pressed)

	_update_digit_text()
	_update_passcode_enabled()


func _on_private_toggled(_is_private: bool) -> void:
	_update_passcode_enabled()


func _on_digit_pressed(index: int) -> void:
	if not private_toggle.button_pressed:
		return

	digits[index] += 1

	if digits[index] > 9:
		digits[index] = 1

	_update_digit_text()


func _on_create_pressed() -> void:
	var passcode := ""

	if private_toggle.button_pressed:
		passcode = _get_passcode()

	create_requested.emit(private_toggle.button_pressed, passcode)


func _on_close_pressed() -> void:
	visible = false
	close_requested.emit()


func _get_passcode() -> String:
	return str(digits[0]) + str(digits[1]) + str(digits[2])


func _update_digit_text() -> void:
	digit_one.text = str(digits[0])
	digit_two.text = str(digits[1])
	digit_three.text = str(digits[2])


func _update_passcode_enabled() -> void:
	var is_private := private_toggle.button_pressed

	digit_one.disabled = not is_private
	digit_two.disabled = not is_private
	digit_three.disabled = not is_private

	if is_private:
		passcode_root.modulate = Color.WHITE
	else:
		passcode_root.modulate = Color(1, 1, 1, 0.35)
