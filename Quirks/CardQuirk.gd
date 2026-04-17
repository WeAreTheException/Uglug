extends Resource
class_name CardQuirk

@export var sigil_texture: Texture2D
@export var quirk_name: String
@export var description: String

func get_attack_target(attacker: Card, opposing_card: Card) -> Card:
	return opposing_card

func modify_damage(attacker: Card, defender: Card, base_damage: int) -> int:
	return base_damage

func on_before_take_damage(card: Card, attacker: Card, amount: int) -> int:
	return amount

func on_death(card: Card) -> void:
	pass

func on_damaged(card: Card, attacker: Card, amount: int) -> void:
	pass

func on_turn_end(card: Card) -> void:
	pass
