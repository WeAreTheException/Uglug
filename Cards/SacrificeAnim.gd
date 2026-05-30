extends Node
class_name SacrificeAnim

@export var wiggle_speed: float = 40
@export var wiggle_degrees: float = 2

var wiggling_card: Card = null
var wiggle_time: float = 0.0
var original_rotation: float = 0.0


func _process(delta: float) -> void:
	if wiggling_card == null:
		return

	if not is_instance_valid(wiggling_card):
		wiggling_card = null
		return

	wiggle_time += delta
	wiggling_card.rotation = original_rotation + sin(wiggle_time * wiggle_speed) * deg_to_rad(wiggle_degrees)


func start_wiggle(card: Card) -> void:
	if card == null:
		return

	wiggling_card = card
	wiggle_time = 0.0
	original_rotation = card.rotation


func stop_wiggle(card: Card) -> void:
	if card == null:
		return

	if wiggling_card == card:
		card.rotation = original_rotation
		wiggling_card = null
