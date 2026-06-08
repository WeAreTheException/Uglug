extends Resource
class_name DeckDefinition

@export var deck_id: String = ""
@export var display_name: String = ""
@export var entries: Array[DeckEntry] = []
@export var starting_hand: StartingHandRecipe


func get_entries() -> Array[DeckEntry]:
	return entries.duplicate()
