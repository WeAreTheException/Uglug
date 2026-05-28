extends Node2D
class_name CardArtRoot

@export var viewport_sprite: Sprite2D
@export var subviewport: SubViewport
@export var visuals_root: Node2D

@export var ant_sprite: Sprite2D

@export var card_image: Sprite2D
@export var card_shadow: Sprite2D
@export var card_border: Sprite2D

@export var base_sigil_container: Node2D
@export var additional_sigil_container: Node2D

@export var card_fog: Sprite2D
@export var background_dots: Sprite2D

@export var stats_visuals: StatsVisuals

var card: CardRoot = null


func _ready() -> void:
	setup_viewport()


func setup_viewport() -> void:
	if viewport_sprite == null:
		return

	if subviewport == null:
		return

	subviewport.transparent_bg = true
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	viewport_sprite.texture = subviewport.get_texture()
	viewport_sprite.centered = true


func setup_from_card(source_card: CardRoot) -> void:
	setup_viewport()

	if source_card == null:
		return

	card = source_card

	if card.card_data != null:
		set_ant_texture(card.card_data.ant_texture)

	if stats_visuals != null:
		stats_visuals.setup_from_card(card)

	if card.mutations != null:
		if not card.mutations.mutations_changed.is_connected(update_sigils):
			card.mutations.mutations_changed.connect(update_sigils)

	update_sigils()


func set_ant_texture(texture: Texture2D) -> void:
	if ant_sprite == null:
		return

	ant_sprite.texture = texture
	ant_sprite.visible = texture != null


func set_card_texture(texture: Texture2D) -> void:
	if card_image == null:
		return

	card_image.texture = texture
	card_image.visible = texture != null


func update_sigils() -> void:
	clear_base_sigils()
	clear_additional_sigils()

	if card == null:
		return

	if card.mutations == null:
		return

	var runtimes := card.mutations.get_all_runtimes()

	for i in range(runtimes.size()):
		var runtime := runtimes[i]

		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		set_sigil(i, runtime.mutation.sigil_texture, runtime.is_greyed_out)


func set_sigil(index: int, texture: Texture2D, greyed_out: bool = false) -> void:
	if index < 0:
		return

	if index < _get_base_sigil_count():
		_set_sigil_texture(base_sigil_container, index, texture, greyed_out)
		return

	var additional_index := index - _get_base_sigil_count()

	_set_sigil_texture(
		additional_sigil_container,
		additional_index,
		texture,
		greyed_out
	)


func clear_base_sigils() -> void:
	_clear_sigils(base_sigil_container)


func clear_additional_sigils() -> void:
	_clear_sigils(additional_sigil_container)


func _set_sigil_texture(
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

	var child := container.get_child(index)

	if child is Sprite2D:
		child.texture = texture
		child.visible = texture != null
		child.modulate.a = 0.35 if greyed_out else 1.0


func _clear_sigils(container: Node2D) -> void:
	if container == null:
		return

	for child in container.get_children():
		if child is Sprite2D:
			child.texture = null
			child.visible = false
			child.modulate.a = 1.0


func _get_base_sigil_count() -> int:
	if base_sigil_container == null:
		return 0

	return base_sigil_container.get_child_count()
