extends Node2D
class_name CardMutationVisuals

@export var base_sigil_container: Node2D
@export var additional_sigil_container: Node2D
@export var greyed_out_alpha: float = 0.35


func display_runtimes(runtimes: Array[MutationRuntime]) -> void:
	clear_all()

	if runtimes.is_empty():
		return

	for i in range(runtimes.size()):
		var runtime := runtimes[i]

		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if i == 0:
			_set_sigil_in_container(
				base_sigil_container,
				0,
				runtime.mutation.sigil_texture,
				runtime.is_greyed_out
			)
		else:
			_set_sigil_in_container(
				additional_sigil_container,
				i - 1,
				runtime.mutation.sigil_texture,
				runtime.is_greyed_out
			)


func clear_all() -> void:
	_clear_container(base_sigil_container)
	_clear_container(additional_sigil_container)


func _set_sigil_in_container(
	container: Node2D,
	index: int,
	texture: Texture2D,
	greyed_out: bool
) -> void:
	if container == null:
		return

	if index < 0:
		return

	if index >= container.get_child_count():
		return

	var sprite := container.get_child(index) as Sprite2D

	if sprite == null:
		return

	sprite.texture = texture
	sprite.visible = texture != null
	sprite.modulate.a = greyed_out_alpha if greyed_out else 1.0


func _clear_container(container: Node2D) -> void:
	if container == null:
		return

	for child in container.get_children():
		var sprite := child as Sprite2D

		if sprite == null:
			continue

		sprite.texture = null
		sprite.visible = false
		sprite.modulate.a = 1.0
