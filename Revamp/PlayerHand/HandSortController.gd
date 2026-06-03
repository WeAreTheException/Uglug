extends Node
class_name Hand_SortController

var card_spawner: Hand_CardSpawner = null

@export var cost_ascending: bool = true
@export var mutation_count_ascending: bool = true

var sort_enabled: bool = true


func setup(source_card_spawner: Hand_CardSpawner) -> void:
	card_spawner = source_card_spawner


func set_sort_enabled(value: bool) -> void:
	sort_enabled = value


func sort_by_cost() -> void:
	if not sort_enabled:
		return

	if card_spawner == null:
		return

	card_spawner.sort_cards(func(a: CardRoot, b: CardRoot) -> bool:
		var a_cost := _get_card_cost(a)
		var b_cost := _get_card_cost(b)

		if a_cost == b_cost:
			return false

		if cost_ascending:
			return a_cost < b_cost

		return a_cost > b_cost
	)


func sort_by_mutation_count() -> void:
	if not sort_enabled:
		return

	if card_spawner == null:
		return

	card_spawner.sort_cards(func(a: CardRoot, b: CardRoot) -> bool:
		var a_count := _get_mutation_count(a)
		var b_count := _get_mutation_count(b)

		if a_count == b_count:
			return false

		if mutation_count_ascending:
			return a_count < b_count

		return a_count > b_count
	)


func _get_card_cost(card: CardRoot) -> int:
	if card == null:
		return 0

	return card.get_sacrifice_cost()


func _get_mutation_count(card: CardRoot) -> int:
	if card == null:
		return 0

	if card.mutations == null:
		return 0

	return card.mutations.get_all_runtimes().size()
