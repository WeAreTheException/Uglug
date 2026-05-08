extends Node2D
class_name MutationInstance

@export var mutation_sprite: Sprite2D
@export var mutation_name_label: Label

var mutation: Mutation = null

func setup_mutation(new_mutation: Mutation) -> void:
	mutation = new_mutation

	if mutation == null:
		return

	if mutation_name_label != null:
		mutation_name_label.text = mutation.mutation_name

	if mutation_sprite != null:
		mutation_sprite.texture = mutation.sigil_texture
