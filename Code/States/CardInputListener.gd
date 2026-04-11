extends Area2D
class_name CardInputListener

signal hovered(card)
signal hovered_off(card)
signal pressed(card)
signal released(card)
signal slot_entered(slot)
signal slot_exited(slot)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_mouse_entered() -> void:
	hovered.emit(self)

func _on_mouse_exited() -> void:
	hovered_off.emit(self)

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressed.emit(self)
		else:
			released.emit(self)

func _on_area_entered(area: Area2D) -> void:
	if area is CardSlot:
		slot_entered.emit(area)

func _on_area_exited(area: Area2D) -> void:
	if area is CardSlot:
		slot_exited.emit(area)
