extends Node

@export var mutation: Mutation
@export var test_sprite: Sprite2D

func _ready() -> void:
	if mutation == null:
		print("mutation is null")
		return

	print("mutation resource path: ", mutation.resource_path)
	print("mutation script: ", mutation.get_script())
	print("sigil texture: ", mutation.sigil_texture)

	if test_sprite != null:
		test_sprite.texture = mutation.sigil_texture
