extends Resource
class_name DeckSplitRules

enum SplitMode {
	PURE_RANDOM,
	TYPE_BALANCED,
	TYPE_AND_COST_BALANCED
}

@export var split_mode: SplitMode = SplitMode.PURE_RANDOM
@export var force_even_pool: bool = false
@export var one_legendary_per_player: bool = false


func uses_pure_random() -> bool:
	return split_mode == SplitMode.PURE_RANDOM
