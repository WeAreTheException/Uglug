extends Node
class_name PlayerHandButtonsRoot

signal prime_pressed

@export var prime_button: BaseButton


func _ready() -> void:
	if prime_button != null:
		prime_button.pressed.connect(_on_prime_pressed)

	set_prime_enabled(false)
	set_prime_text("Prime")


func set_prime_enabled(value: bool) -> void:
	if prime_button == null:
		return

	prime_button.disabled = not value


func set_prime_text(text: String) -> void:
	if prime_button == null:
		return

	prime_button.text = text


func _on_prime_pressed() -> void:
	prime_pressed.emit()
