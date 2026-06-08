extends Resource
class_name ClassDefinition

@export var class_id: String = ""
@export var display_name: String = "Uglug Classic"
@export var default_deck: DeckDefinition
@export var split_rules: DeckSplitRules
@export var allowed_decks: Array[DeckDefinition] = []


func get_default_deck() -> DeckDefinition:
	return default_deck


func get_split_rules() -> DeckSplitRules:
	return split_rules
