extends Node
class_name DrawPileView

@export var visible_root: CanvasItem


func set_cards_left(cards_left: int) -> void:
	if visible_root != null:
		visible_root.visible = cards_left > 0
