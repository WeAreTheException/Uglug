extends RefCounted
class_name PlayerLoadoutBuilderHelper

var pool_builder := DeckPoolBuilderHelper.new()
var shuffler := SeededShuffleHelper.new()
var starting_helper := StartingHandBuilderHelper.new()


func build(p1_loadout: PlayerDeckLoadout, p2_loadout: PlayerDeckLoadout, seed_value: int, worker_card: CardData) -> Dictionary:
	var p1 := _build_player(p1_loadout, seed_value + 11, worker_card)
	var p2 := _build_player(p2_loadout, seed_value + 29, worker_card)
	return {
		"p1_draw_pile": p1["remaining_draw_pile"],
		"p2_draw_pile": p2["remaining_draw_pile"],
		"p1_starting_hand": p1["starting_hand"],
		"p2_starting_hand": p2["starting_hand"]
	}


func _build_player(loadout: PlayerDeckLoadout, seed_value: int, worker_card: CardData) -> Dictionary:
	if loadout == null:
		return {"remaining_draw_pile": [], "starting_hand": []}
	var pool := pool_builder.build_pool(loadout.get_deck())
	var shuffled := shuffler.shuffle_cards(pool, seed_value)
	return starting_helper.build(shuffled, loadout.get_starting_hand(), worker_card)
