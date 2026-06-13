extends Node
class_name WorkerSource

signal worker_requested(card_data: CardData)

@export var worker_card: CardData
@export var view: WorkerPileView
@export var print_debug: bool = true


func get_worker_card() -> CardData:
	if worker_card == null:
		return null

	worker_requested.emit(worker_card)

	if view != null:
		view.show_worker_requested()

	return worker_card


func build_worker_cards_from_source(
	source_card: CardRoot,
	amount: int
) -> Array[CardData]:
	var result: Array[CardData] = []

	if amount <= 0:
		return result

	var inherited_mutations: Array[Mutation] = _get_inherited_mutations(source_card)

	for i: int in range(amount):
		var base_worker: CardData = get_worker_card()

		if base_worker == null:
			if print_debug:
				print("WorkerSource blocked: worker_card missing")
			break

		var worker_copy: CardData = _make_worker_copy(base_worker)

		if worker_copy == null:
			continue

		for mutation: Mutation in inherited_mutations:
			if mutation == null:
				continue

			worker_copy.additional_mutations.append(mutation)

		result.append(worker_copy)

	return result


func _get_inherited_mutations(source_card: CardRoot) -> Array[Mutation]:
	if source_card == null:
		return []

	if not is_instance_valid(source_card):
		return []

	if source_card.mutations == null:
		return []

	return source_card.mutations.get_inheritable_mutations()


func _make_worker_copy(base_worker: CardData) -> CardData:
	if base_worker == null:
		return null

	var copy: CardData = base_worker.duplicate(true) as CardData

	if copy == null:
		return null

	copy.base_mutations = base_worker.base_mutations.duplicate()
	copy.additional_mutations = base_worker.additional_mutations.duplicate()

	return copy
