extends Node
class_name MutationHandler

var card: Card = null


func _ready() -> void:
	card = get_parent() as Card

	if card == null:
		return

	hide_all_sigils()


func setup_from_card_data(data: CardData) -> void:
	if card == null:
		card = get_parent() as Card

	if card == null:
		return

	if data == null:
		return

	card.base_mutations = data.base_mutations.duplicate()
	card.additional_mutations = []

	call_deferred("update_sigils")


func hide_all_sigils() -> void:
	if card == null:
		card = get_parent() as Card

	if card == null:
		return

	if card.card_art == null:
		return

	card.card_art.clear_base_sigils()
	card.card_art.clear_additional_sigils()


func add_additional_mutation(mutation: Mutation) -> void:
	if card == null:
		return

	if mutation == null:
		return

	card.additional_mutations.append(mutation)
	update_sigils()


func add_additional_mutation_from_path(mutation_path: String) -> void:
	if mutation_path == "":
		return

	var mutation := load(mutation_path) as Mutation

	if mutation == null:
		return

	add_additional_mutation(mutation)


func get_additional_mutation_paths() -> Array[String]:
	var paths: Array[String] = []

	if card == null:
		return paths

	for mutation in card.additional_mutations:
		if mutation == null:
			continue

		if mutation.resource_path == "":
			continue

		paths.append(mutation.resource_path)

	return paths


func get_all_mutations() -> Array[Mutation]:
	var combined: Array[Mutation] = []

	if card == null:
		return combined

	for mutation in card.base_mutations:
		if mutation != null:
			combined.append(mutation)

	for mutation in card.additional_mutations:
		if mutation != null:
			combined.append(mutation)

	return combined


func update_sigils() -> void:
	if card == null:
		card = get_parent() as Card

	if card == null:
		return

	if card.card_art == null:
		return

	card.card_art.clear_base_sigils()
	card.card_art.clear_additional_sigils()

	for i in range(card.base_mutations.size()):
		var mutation := card.base_mutations[i]

		if mutation == null:
			continue

		card.card_art.set_base_sigil(i, mutation.sigil_texture)

	for i in range(card.additional_mutations.size()):
		var mutation := card.additional_mutations[i]

		if mutation == null:
			continue

		card.card_art.set_additional_sigil(i, mutation.sigil_texture)
