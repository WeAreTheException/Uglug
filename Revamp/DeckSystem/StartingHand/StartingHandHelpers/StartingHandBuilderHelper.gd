extends RefCounted
class_name StartingHandBuilderHelper


func build(draw_pile: Array[CardData], recipe: StartingHandRecipe, worker_card: CardData) -> Dictionary:
	var result := {
		"starting_hand": [],
		"remaining_draw_pile": draw_pile.duplicate()
	}
	if recipe == null:
		return result
	_add_fixed_cards(result, recipe)
	_add_random_warriors(result, recipe)
	_add_workers(result, recipe, worker_card)
	return result


func _add_fixed_cards(result: Dictionary, recipe: StartingHandRecipe) -> void:
	for card_data in recipe.fixed_starting_cards:
		if card_data == null:
			continue
		result["starting_hand"].append(card_data)
		if recipe.remove_fixed_cards_from_draw_pile:
			result["remaining_draw_pile"].erase(card_data)


func _add_random_warriors(result: Dictionary, recipe: StartingHandRecipe) -> void:
	for i in range(recipe.random_warrior_cards):
		if result["remaining_draw_pile"].is_empty():
			return
		result["starting_hand"].append(result["remaining_draw_pile"].pop_front())


func _add_workers(result: Dictionary, recipe: StartingHandRecipe, worker_card: CardData) -> void:
	if worker_card == null:
		return
	for i in range(recipe.fixed_worker_cards):
		result["starting_hand"].append(worker_card)
