extends RefCounted
class_name HandDragMoverHelper


func apply_drag_position(card: CardRoot, drag_offset: Vector2, z_index: int) -> void:
	if card == null:
		return

	card.global_position = card.get_global_mouse_position() + drag_offset
	card.z_index = z_index
