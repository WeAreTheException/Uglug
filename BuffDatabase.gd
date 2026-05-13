extends Node
class_name BuffDatabase

@export var starting_mutations: Array[Mutation] = []

var mutation_deck: Array[Mutation] = []

func _ready() -> void:
	reset_deck()

func reset_deck() -> void:
	mutation_deck = starting_mutations.duplicate()
	mutation_deck.shuffle()

	print("Buff deck created with ", mutation_deck.size(), " mutations")

func get_random_mutation() -> Mutation:
	if mutation_deck.is_empty():
		print("Buff deck empty")
		return null

	var mutation: Mutation = mutation_deck.pop_back() as Mutation

	print("Buff deck pulled mutation. Remaining: ", mutation_deck.size())

	return mutation

func get_remaining_count() -> int:
	return mutation_deck.size()
