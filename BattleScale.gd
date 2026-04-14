extends Node
class_name BattleScale

@export var win_value: int = 5

var current_value: int = 0

func add_damage(amount: int) -> void:
	current_value += amount

	print("scale: ", current_value, "/", win_value)

	if current_value >= win_value:
		print("you win")
