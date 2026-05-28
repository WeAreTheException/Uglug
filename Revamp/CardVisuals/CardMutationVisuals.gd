extends Node2D
class_name CardMutationVisuals

@export var mutation_container: Node2D
@export var greyed_out_alpha: float = 0.35


func display_runtimes(runtimes: Array[MutationRuntime]) -> void:
	clear_all()

	if mutation_container == null:
		return

	for i in range(runtimes.size()):
		if i >= mutation_container.get_child_count():
			return

		var runtime := runtimes[i]

		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		_set_mutation_sprite(
			i,
			runtime.mutation.sigil_texture,
			runtime.is_greyed_out
		)


func clear_all() -> void:
	if mutation_container == null:
		return

	for child in mutation_container.get_children():
		var sprite := child as Sprite2D

		if sprite == null:
			continue

		sprite.texture = null
		sprite.visible = false
		sprite.modulate.a = 1.0


func _set_mutation_sprite(index: int, texture: Texture2D, greyed_out: bool) -> void:
	if mutation_container == null:
		return

	if index < 0:
		return

	if index >= mutation_container.get_child_count():
		return

	var sprite := mutation_container.get_child(index) as Sprite2D

	if sprite == null:
		return

	sprite.texture = texture
	sprite.visible = texture != null
	sprite.modulate.a = greyed_out_alpha if greyed_out else 1.0
