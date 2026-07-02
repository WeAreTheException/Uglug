extends Control
class_name MutationToolTip

@export var name_label: Label
@export var description_label: Label

@export var default_name_text: String = "Mutation"
@export_multiline var default_description_text: String = "Hover over a mutation to see what it does."

@export var show_default_on_ready: bool = true

var current_mutation: Mutation = null


func _ready() -> void:
	if show_default_on_ready:
		show_default_tooltip()


func show_mutation(mutation: Mutation) -> void:
	current_mutation = mutation

	if mutation == null:
		show_default_tooltip()
		return

	if name_label != null:
		name_label.text = mutation.mutation_name

	if description_label != null:
		description_label.text = mutation.mutation_description

	visible = true
	show()


func hide_tooltip() -> void:
	show_default_tooltip()


func show_default_tooltip() -> void:
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

	if visible and current_mutation == mutation:
		show_default_tooltip()
		return

	show_mutation(mutation)
