extends Area2D
class_name CardInput

signal hovered
signal unhovered
signal pressed
signal released

var is_hovered: bool = false


func _ready() -> void:
	input_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	print("CardInput ready")
	print("input_pickable = ", input_pickable)


func _input(event: InputEvent) -> void:
	if not is_hovered:
		return

	if event is InputEventMouseButton:
		print("MOUSE BUTTON WHILE HOVERED: ", event)

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("CARD CLICK REGISTERED")
				pressed.emit()
			else:
				print("CARD RELEASE REGISTERED")
				released.emit()


func _on_mouse_entered() -> void:
	is_hovered = true
	print("CARD HOVER ENTERED")
	hovered.emit()


func _on_mouse_exited() -> void:
	is_hovered = false
	print("CARD HOVER EXITED")
	unhovered.emit()
