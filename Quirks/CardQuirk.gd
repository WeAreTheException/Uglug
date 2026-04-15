extends Resource
class_name CardQuirk

func get_attack_target(attacker: Card, opposing_card: Card) -> Card:
	return opposing_card

func modify_damage(attacker: Card, defender: Card, base_damage: int) -> int:
	return base_damage
