extends Node
class_name ViewportDisplayController

@export var viewport_container: Control
@export var viewport_root: Node

func setup_from_card(_card: CardRoot) -> void:
	pass

func set_visible_safe(value: bool) -> void:
	if viewport_container != null:
		viewport_container.visible = value

func get_viewport_root() -> Node:
	return viewport_root
