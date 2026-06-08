extends Resource
class_name CardData

enum CardRarity {
	COMMON,
	EPIC,
	LEGENDARY
}

enum CardPileType {
	WORKER,
	WARRIOR,
	TOKEN
}

enum CardType {
	TARGET,
	SUSTAIN,
	STRAIGHT_CHOPS,
	INVESTMENT,
	RALLY,
	RETALIATION,
	PURISTS,
	INHERITANCE,
	MOVER,
	GAMBLE
}

@export var card_id: String = ""
@export var name: String = ""
@export var rarity: CardRarity = CardRarity.COMMON
@export var pile_type: CardPileType = CardPileType.WARRIOR
@export var card_type: CardType = CardType.STRAIGHT_CHOPS

@export var attack: int = 0
@export var health: int = 1
@export var cost: int = 0
@export var worth: int = 1

@export var background_texture: Texture2D
@export var ant_texture: Texture2D

@export var base_mutations: Array[Mutation] = []
@export var additional_mutations: Array[Mutation] = []
@export var deck_amount: int = 1


func get_safe_card_id() -> String:
	if card_id.strip_edges() != "":
		return card_id
	return name.to_snake_case()
