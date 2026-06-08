extends RefCounted
class_name ClassicSplitBuilderHelper

var pool_builder := DeckPoolBuilderHelper.new()
var split_helper := PureRandomSplitHelper.new()
var starting_helper := StartingHandBuilderHelper.new()


func build(class_definition: ClassDefinition, seed_value: int, worker_card: CardData) -> Dictionary:
	if class_definition == null:
		return {}
	var deck := class_definition.get_default_deck()
	if deck == null:
		return {}
	var pool := pool_builder.build_pool(deck)
	var split := split_helper.split(pool, seed_value)
	var p1_start := starting_helper.build(split["p1"], deck.starting_hand, worker_card)
	var p2_start := starting_helper.build(split["p2"], deck.starting_hand, worker_card)
	return {
		"p1_draw_pile": p1_start["remaining_draw_pile"],
		"p2_draw_pile": p2_start["remaining_draw_pile"],
		"p1_starting_hand": p1_start["starting_hand"],
		"p2_starting_hand": p2_start["starting_hand"]
	}
