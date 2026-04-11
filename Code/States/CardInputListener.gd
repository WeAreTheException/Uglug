extends Area2D
class_name CardInputListener

signal hovered(card)
signal hovered_off(card)

func _on_mouse_entered() -> void:
	hovered.emit(self)

func _on_mouse_exited() -> void:
	hovered_off.emit(self)
