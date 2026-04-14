extends Node
class_name BattleScale

@export var win_value: int = 5

var current_value: int = 0

func add_direct_damage(amount: int, owner: int) -> void:
	if owner == Card.Owner.PLAYER:
		current_value += amount
	elif owner == Card.Owner.OPPONENT:
		current_value -= amount

	print("scale: ", current_value)

	if current_value >= win_value:
		print("you win")
	elif current_value <= -win_value:
		print("you lose")
