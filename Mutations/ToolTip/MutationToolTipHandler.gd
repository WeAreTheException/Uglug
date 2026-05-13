extends Node2D
class_name MutationTooltipHandler

@export var tooltip_root: Control
@export var name_label: Control
@export var description_label: Control

@export var base_sigil_sprites: Array[Sprite2D]
@export var additional_sigil_sprites: Array[Sprite2D]

@export var follow_mouse: bool = true
@export var tooltip_offset: Vector2 = Vector2(18, 18)

var card: Card = null


func _ready() -> void:
	card = _find_card_parent()
	_hide_tooltip()


func _process(_delta: float) -> void:
	if card == null:
		card = _find_card_parent()

	var mutation := _get_hovered_mutation()

	if mutation == null:
		_hide_tooltip()
		return

	_show_tooltip(mutation)


func _get_hovered_mutation() -> Mutation:
	if card == null:
		return null

	for i in base_sigil_sprites.size():
		if i >= card.base_mutations.size():
			continue

		var sprite := base_sigil_sprites[i]
		var mutation: Mutation = card.base_mutations[i]

		if mutation != null and _is_mouse_over_sprite(sprite):
			return mutation

	for i in additional_sigil_sprites.size():
		if i >= card.additional_mutations.size():
			continue

		var sprite := additional_sigil_sprites[i]
		var mutation: Mutation = card.additional_mutations[i]

		if mutation != null and _is_mouse_over_sprite(sprite):
			return mutation

	return null


func _is_mouse_over_sprite(sprite: Sprite2D) -> bool:
	if sprite == null:
		return false

	if not sprite.visible:
		return false

	if sprite.texture == null:
		return false

	var local_mouse := sprite.to_local(get_global_mouse_position())
	return sprite.get_rect().has_point(local_mouse)


func _show_tooltip(mutation: Mutation) -> void:
	if tooltip_root == null:
		return

	tooltip_root.visible = true

	if follow_mouse:
		tooltip_root.global_position = get_viewport().get_mouse_position() + tooltip_offset

	if name_label != null:
		name_label.set("text", mutation.get_tooltip_name())

	if description_label != null:
		description_label.set("text", mutation.get_tooltip_description())


func _hide_tooltip() -> void:
	if tooltip_root != null:
		tooltip_root.visible = false


func _find_card_parent() -> Card:
	var current: Node = self

	while current != null:
		if current is Card:
			return current

		current = current.get_parent()

	return null
