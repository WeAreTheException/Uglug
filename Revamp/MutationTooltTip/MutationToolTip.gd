extends Control
class_name MutationToolTip

@export_group("Labels")
@export var name_label: Label
@export var description_label: Label

@export_group("Default Text")
@export var default_name_text: String = "Mutation"

@export_multiline var default_description_text: String = (
	"Hover over a card to see its mutations."
)

@export var no_mutations_text: String = "No mutations."

@export_group("Behaviour")
@export var show_default_on_ready: bool = true

var current_mutation: Mutation = null
var current_card: CardRoot = null


func _ready() -> void:
	if show_default_on_ready:
		show_default_tooltip()
	else:
		hide()


func show_card(card: CardRoot) -> void:
	if card == null:
		show_default_tooltip()
		return

	if not is_instance_valid(card):
		show_default_tooltip()
		return

	current_card = card
	current_mutation = null

	if name_label != null:
		name_label.text = _get_card_display_name(card)

	if description_label != null:
		description_label.text = _build_card_mutation_text(card)

	visible = true
	show()


func show_mutation(mutation: Mutation) -> void:
	if mutation == null:
		show_default_tooltip()
		return

	current_card = null
	current_mutation = mutation

	if name_label != null:
		name_label.text = mutation.mutation_name

	if description_label != null:
		description_label.text = mutation.mutation_description

	visible = true
	show()


func hide_tooltip() -> void:
	show_default_tooltip()


func show_default_tooltip() -> void:
	current_card = null
	current_mutation = null

	if name_label != null:
		name_label.text = default_name_text

	if description_label != null:
		description_label.text = default_description_text

	visible = true
	show()


func toggle_mutation(mutation: Mutation) -> void:
	if mutation == null:
		show_default_tooltip()
		return

	if current_mutation == mutation:
		show_default_tooltip()
		return

	show_mutation(mutation)


func _get_card_display_name(card: CardRoot) -> String:
	var display_name: String = card.card_name.strip_edges()

	if display_name != "":
		return display_name

	return card.name


func _build_card_mutation_text(card: CardRoot) -> String:
	if card.mutations == null:
		return no_mutations_text

	var mutation_list: Array[Mutation] = (
		card.mutations.get_all_mutations()
	)

	var lines: Array[String] = []

	for mutation: Mutation in mutation_list:
		if mutation == null:
			continue

		var mutation_name: String = (
			mutation.mutation_name.strip_edges()
		)
		var mutation_description: String = (
			mutation.mutation_description.strip_edges()
		)

		if mutation_name == "" and mutation_description == "":
			continue

		if mutation_name == "":
			lines.append(mutation_description)
			continue

		if mutation_description == "":
			lines.append(mutation_name)
			continue

		lines.append(
			"%s: %s" % [
				mutation_name,
				mutation_description
			]
		)

	if lines.is_empty():
		return no_mutations_text

	return "\n".join(lines)
