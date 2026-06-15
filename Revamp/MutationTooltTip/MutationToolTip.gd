extends Control
class_name MutationToolTip

@export var name_label: Label
@export var description_label: Label
@export var hide_on_ready: bool = true

var current_mutation: Mutation = null


func _ready() -> void:
	if hide_on_ready:
		hide_tooltip()


func show_mutation(mutation: Mutation) -> void:
	current_mutation = mutation

	if mutation == null:
		print("TOOLTIP BLOCKED: mutation null")
		hide_tooltip()
		return

	print("TOOLTIP SHOWING: ", mutation.mutation_name)

	if name_label != null:
		name_label.text = mutation.mutation_name
	else:
		print("TOOLTIP WARNING: name_label missing")

	if description_label != null:
		description_label.text = mutation.mutation_description
	else:
		print("TOOLTIP WARNING: description_label missing")

	visible = true
	show()


func hide_tooltip() -> void:
	current_mutation = null
	visible = false
	hide()


func toggle_mutation(mutation: Mutation) -> void:
	if mutation == null:
		print("TOOLTIP TOGGLE BLOCKED: mutation null")
		hide_tooltip()
		return

	if visible and current_mutation == mutation:
		print("TOOLTIP HIDING: ", mutation.mutation_name)
		hide_tooltip()
		return

	show_mutation(mutation)
