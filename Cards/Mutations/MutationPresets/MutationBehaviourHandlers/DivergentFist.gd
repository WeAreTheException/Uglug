extends Mutation
class_name DivergentFist


func mutation_attack(card: Card) -> bool:
	if card == null:
		return false

	print("Divergent Fist hijacked attack")

	if card.attack_handler == null:
		return true

	card.attack_handler.attack()
	card.attack_handler.attack()

	return true
