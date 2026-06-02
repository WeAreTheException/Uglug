extends Node
class_name HandSortController

@export var hand: PlayerHandRoot

@export var cost_sort_button: BaseButton
@export var mutation_sort_button: BaseButton

@export var cost_ascending: bool = true
@export var mutation_count_ascending: bool = true


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if cost_sort_button != null:
		cost_sort_button.pressed.connect(sort_by_cost)

	if mutation_sort_button != null:
		mutation_sort_button.pressed.connect(sort_by_mutation_count)


func sort_by_cost() -> void:
	if hand == null:
		return

	hand.sort_cards(func(a: CardRoot, b: CardRoot) -> bool:
		var a_cost := _get_card_cost(a)
		var b_cost := _get_card_cost(b)

		if a_cost == b_cost:
			return false

		if cost_ascending:
			return a_cost < b_cost

		return a_cost > b_cost
	)


func sort_by_mutation_count() -> void:
	if hand == null:
		return

	hand.sort_cards(func(a: CardRoot, b: CardRoot) -> bool:
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

	if card.card_data == null:
		return 0

	return card.card_data.cost


func _get_mutation_count(card: CardRoot) -> int:
	if card == null:
		return 0

	if card.mutations == null:
		return 0

	return card.mutations.get_all_runtimes().size()
