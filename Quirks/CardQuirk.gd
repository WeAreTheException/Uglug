extends Resource
class_name CardQuirk

@export var sigil_texture: Texture2D

func get_attack_target(attacker: Card, opposing_card: Card) -> Card:
	return opposing_card

func modify_damage(attacker: Card, defender: Card, base_damage: int) -> int:
	return base_damage

func on_death(card: Card) -> void:
	pass

func on_damaged(card: Card, attacker: Card, amount: int) -> void:
	pass
