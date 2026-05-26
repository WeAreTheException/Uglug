extends Resource
class_name CardData

@export var name: String
@export var attack: int
@export var health: int = 1
@export var cost: int
@export var worth: int = 1

@export var sprite: Texture2D
@export var ant_texture: Texture2D

@export var deck_amount: int = 1
@export var base_mutations: Array[Mutation] = []

var additional_mutations: Array[Mutation] = []
