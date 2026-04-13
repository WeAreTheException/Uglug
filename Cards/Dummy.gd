extends Node2D
class_name Dummy

var health: int = 10

func take_damage(amount: int) -> void:
	health -= amount

	if health < 0:
		health = 0

	print("Dummy took ", amount, " damage. Remaining health: ", health)
