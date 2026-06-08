extends Resource
class_name PlayerDeckLoadout

@export var loadout_id: String = ""
@export var display_name: String = ""
@export var class_definition: ClassDefinition
@export var deck: DeckDefinition
@export var starting_hand_override: StartingHandRecipe


func get_deck() -> DeckDefinition:
	if deck != null:
		return deck
	if class_definition != null:
		return class_definition.get_default_deck()
	return null


func get_starting_hand() -> StartingHandRecipe:
	if starting_hand_override != null:
		return starting_hand_override
	var resolved_deck := get_deck()
	return null if resolved_deck == null else resolved_deck.starting_hand
