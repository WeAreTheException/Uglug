extends Node
class_name CardMutationVisuals

@export var base_sigil_sprites: Array[Sprite2D]
@export var additional_sigil_sprites: Array[Sprite2D]

func clear_all() -> void:
	_clear_sprites(base_sigil_sprites)
	_clear_sprites(additional_sigil_sprites)

func display_runtimes(runtimes: Array[MutationRuntime]) -> void:
	clear_all()
	var index := 0
	for runtime in runtimes:
		if runtime == null or runtime.mutation == null:
			continue
		_set_sigil(index, runtime.mutation.sigil_texture)
		index += 1

func _set_sigil(index: int, texture: Texture2D) -> void:
	var sprites := base_sigil_sprites
	var local_index := index
	if index >= base_sigil_sprites.size():
		sprites = additional_sigil_sprites
		local_index = index - base_sigil_sprites.size()
	if local_index < 0 or local_index >= sprites.size():
		return
	sprites[local_index].texture = texture
	sprites[local_index].visible = texture != null

func _clear_sprites(sprites: Array[Sprite2D]) -> void:
	for sprite in sprites:
		if sprite == null:
			continue
		sprite.texture = null
		sprite.visible = false
