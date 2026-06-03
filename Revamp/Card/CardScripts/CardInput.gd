extends Area2D
class_name CardInput

signal hovered
signal unhovered

var is_hovered: bool = false


func _ready() -> void:
	input_pickable = true

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	is_hovered = true
	hovered.emit()


func _on_mouse_exited() -> void:
	is_hovered = false
	unhovered.emit()
