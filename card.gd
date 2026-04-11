extends Area2D

signal hovered(card)
signal hovered_off(card)

func _ready():
	get_parent().connect_card_signals(self)

func _on_mouse_entered():
	emit_signal("hovered", self)

func _on_mouse_exited():
	emit_signal("hovered_off", self)
	
