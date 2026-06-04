extends Node
class_name Hand_PrimeMover

@export var move_time: float = 0.12
@export var target_rotation_degrees: float = 0.0
@export var target_z_index: int = 150

var prime_controller: Hand_PrimeController = null
var prime_location: Node2D = null
var tween: Tween = null


func setup(
	source_prime_controller: Hand_PrimeController,
	source_prime_location: Node2D
) -> void:
	prime_controller = source_prime_controller
	prime_location = source_prime_location


func move_card_to_anchor(card: CardRoot) -> void:
	if card == null:
		return

	if prime_location == null:
		return

	if tween != null:
		tween.kill()

	card.z_index = target_z_index

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(card, "global_position", prime_location.global_position, move_time)
	tween.parallel().tween_property(card, "rotation_degrees", target_rotation_degrees, move_time)
