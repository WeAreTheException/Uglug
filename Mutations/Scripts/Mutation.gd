extends Resource
class_name Mutation

@export var mutation_name: String = ""
@export_multiline var mutation_description: String = ""
@export var sigil_texture: Texture2D

func get_tooltip_name() -> String:
	if mutation_name.strip_edges() != "":
		return mutation_name

	if resource_path != "":
		return resource_path.get_file().get_basename()

	return "Mutation"

func get_tooltip_description() -> String:
	return mutation_description

func get_attack_target(_attacker: Card, opposing_card: Card) -> Card:
	return opposing_card

func modify_damage(_attacker: Card, _defender: Card, base_damage: int) -> int:
	return base_damage

func on_death(_card: Card) -> void:
	pass

func on_damaged(_card: Card, _attacker: Card, _amount: int) -> void:
	pass

func wants_manual_attack_target() -> bool:
	return false
