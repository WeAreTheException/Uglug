extends Node
class_name StartingHandResolver

var builder := StartingHandBuilderHelper.new()


func build_starting_hand(
	draw_pile: Array[CardData],
	recipe: StartingHandRecipe,
	worker_card: CardData
) -> Dictionary:
	return builder.build(draw_pile, recipe, worker_card)
