extends Resource
class_name Mutation

@export var mutation_name: String = ""
@export_multiline var mutation_description: String = ""
@export var sigil_texture: Texture2D


func mutation_attack(_card: Card) -> bool:
	return false


func on_death(_card: Card) -> void:
	pass


func on_damaged(
	_card: Card,
	_attacker: Card,
	_damage: int
) -> void:
	pass


func modify_damage(
	_card: Card,
	_target: Card,
	damage: int
) -> int:
	return damage


func get_attack_target(
	_card: Card,
	target: Card
) -> Card:
	return target


func get_attack_targets(
	_card: Card,
	targets: Array[Card]
) -> Array[Card]:
	return targets
