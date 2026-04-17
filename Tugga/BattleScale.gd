extends Node
class_name BattleScale

signal scale_changed(value: int)

@export var win_value: int = 5

var current_value: int = 0

func add_direct_damage(amount: int, owner: int) -> void:
	if owner == Card.Owner.PLAYER:
		current_value += amount
	elif owner == Card.Owner.OPPONENT:
		current_value -= amount

	current_value = clamp(current_value, -win_value, win_value)

	scale_changed.emit(current_value)

	print("scale: ", current_value)

	if current_value >= win_value:
		print("you win")
	elif current_value <= -win_value:
		print("you lose")
