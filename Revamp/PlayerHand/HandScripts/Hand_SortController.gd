extends Node
class_name Hand_SortController

var card_spawner: Hand_CardSpawner = null

@export var cost_ascending: bool = true
@export var mutation_count_ascending: bool = true


func setup(source_card_spawner: Hand_CardSpawner) -> void:
	card_spawner = source_card_spawner


func sort_by_cost() -> void:
	if card_spawner == null:
		return

	card_spawner.sort_cards(func(a: CardRoot, b: CardRoot) -> bool:
		var a_cost := _get_card_cost(a)
		var b_cost := _get_card_cost(b)

		return a_cost < b_cost if cost_ascending else a_cost > b_cost
	)


func sort_by_mutation_count() -> void:
	if card_spawner == null:
		return

	card_spawner.sort_cards(func(a: CardRoot, b: CardRoot) -> bool:
		var a_count := _get_mutation_count(a)
		var b_count := _get_mutation_count(b)

		return a_count < b_count if mutation_count_ascending else a_count > b_count
	)


func _get_card_cost(card: CardRoot) -> int:
	if card == null or card.card_data == null:
		return 0

	return card.card_data.cost


func _get_mutation_count(card: CardRoot) -> int:
	if card == null or card.mutations == null:
		return 0

	return card.mutations.get_all_runtimes().size()
