extends Node
class_name Hand_PrimeMover

@export var move_time: float = 0.12
@export var target_rotation_degrees: float = 0.0

var prime_controller: Hand_PrimeController = null
var prime_location: Node2D = null
var tween: Tween = null


func setup(
	source_prime_controller: Hand_PrimeController,
	source_prime_location: Node2D
) -> void:
	prime_controller = source_prime_controller
	prime_location = source_prime_location


func move_card_to_anchor(_card: CardRoot) -> void:
	pass
