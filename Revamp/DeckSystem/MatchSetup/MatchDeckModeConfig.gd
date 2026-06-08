extends Node
class_name MatchDeckModeConfig

enum DeckMode {
	UGLUG_CLASSIC_SHARED_SPLIT,
	CUSTOM_PLAYER_LOADOUTS
}

@export var deck_mode: DeckMode = DeckMode.UGLUG_CLASSIC_SHARED_SPLIT
@export var print_debug_results: bool = true


func is_classic_split() -> bool:
	return deck_mode == DeckMode.UGLUG_CLASSIC_SHARED_SPLIT


func is_custom_loadout() -> bool:
	return deck_mode == DeckMode.CUSTOM_PLAYER_LOADOUTS
