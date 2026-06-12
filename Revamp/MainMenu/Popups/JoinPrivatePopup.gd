extends Control
class_name JoinPrivatePopup

signal enter_requested(passcode: String)
signal close_requested

@export var digit_one: Button
@export var digit_two: Button
@export var digit_three: Button
@export var enter_button: Button
@export var close_button: Button
@export var incorrect_password_label: Label
@export var lobby_no_longer_exists_label: Label

@export var flash_time := 0.15
@export var flash_count := 3

var digits := [0, 0, 0]
var flash_tween: Tween


func _ready() -> void:
	visible = false

	_hide_error_labels()

	digit_one.pressed.connect(_on_digit_pressed.bind(0))
	digit_two.pressed.connect(_on_digit_pressed.bind(1))
	digit_three.pressed.connect(_on_digit_pressed.bind(2))
	enter_button.pressed.connect(_on_enter_pressed)
	close_button.pressed.connect(_on_close_pressed)

	_update_digit_text()


func open() -> void:
	visible = true
	_hide_error_labels()


func close() -> void:
	visible = false
	_hide_error_labels()


func flash_incorrect_password() -> void:
	_flash_label(incorrect_password_label)


func flash_lobby_no_longer_exists() -> void:
	_flash_label(lobby_no_longer_exists_label)


func _on_digit_pressed(index: int) -> void:
	digits[index] += 1

	if digits[index] > 9:
		digits[index] = 0

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


func _flash_label(label: Label) -> void:
	if label == null:
		return

	_hide_error_labels()

	if flash_tween != null:
		flash_tween.kill()

	label.visible = true
	label.modulate.a = 1.0

	flash_tween = create_tween()

	for i in range(flash_count):
		flash_tween.tween_property(label, "modulate:a", 0.0, flash_time)
		flash_tween.tween_property(label, "modulate:a", 1.0, flash_time)


func _hide_error_labels() -> void:
	if flash_tween != null:
		flash_tween.kill()
		flash_tween = null

	if incorrect_password_label != null:
		incorrect_password_label.visible = false
		incorrect_password_label.modulate.a = 1.0

	if lobby_no_longer_exists_label != null:
		lobby_no_longer_exists_label.visible = false
		lobby_no_longer_exists_label.modulate.a = 1.0
