extends Node
class_name DrawPileCounter

@export var label: Label


func set_count(cards_left: int) -> void:
	if label != null:
		label.text = str(cards_left)
