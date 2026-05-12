extends Node2D
class_name MutationInstance

@export var sprite: Sprite2D

var mutation: Mutation = null

func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

func setup_mutation(new_mutation: Mutation) -> void:
	mutation = new_mutation

	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

	if mutation == null:
		print("MutationInstance blocked: mutation is null")
		return

	if sprite == null:
		print("MutationInstance blocked: Sprite2D missing")
		return

	if mutation.sigil_texture == null:
		print("MutationInstance blocked: mutation sigil_texture is null")
		return

	sprite.texture = mutation.sigil_texture
	sprite.visible = true
