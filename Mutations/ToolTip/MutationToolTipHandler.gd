extends Node2D
class_name MutationTooltipHandler

@export var tooltip_scene: PackedScene

@export var base_sigil_sprites: Array[Sprite2D]
@export var additional_sigil_sprites: Array[Sprite2D]

@export var card_top_offset: Vector2 = Vector2(60, -140)
@export var tooltip_gap: float = 12.0

var tooltip_instance: Control = null
var tooltip_root: Control = null
var name_label: Label = null
var description_label: Label = null

var card: Card = null


func _ready() -> void:
	card = _find_card_parent()

	_create_tooltip()
	_hide_tooltip()


func _exit_tree() -> void:
	if tooltip_instance != null:
		tooltip_instance.queue_free()


func _process(_delta: float) -> void:
	var mutation := _get_hovered_mutation()

	if mutation == null:
		_hide_tooltip()
		return

	_show_tooltip(mutation)


func _create_tooltip() -> void:
	if tooltip_scene == null:
		push_warning("MutationTooltipHandler: tooltip_scene is not assigned.")
		return

	tooltip_instance = tooltip_scene.instantiate() as Control

	if tooltip_instance == null:
		push_warning("MutationTooltipHandler: tooltip_scene root must be a Control.")
		return

	get_tree().current_scene.add_child(tooltip_instance)

	tooltip_root = tooltip_instance

	name_label = tooltip_instance.find_child("NameLabel", true, false) as Label
	description_label = tooltip_instance.find_child("DescriptionLabel", true, false) as Label

	tooltip_instance.visible = false
	tooltip_root.visible = false

	tooltip_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in tooltip_instance.find_children("*", "Control", true, false):
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _show_tooltip(mutation: Mutation) -> void:
	if tooltip_instance == null:
		return

	if tooltip_root == null:
		return

	if card == null:
		return

	tooltip_instance.visible = true
	tooltip_root.visible = true

	if name_label != null:
		name_label.text = mutation.get_tooltip_name()

	if description_label != null:
		description_label.text = mutation.get_tooltip_description()

	await get_tree().process_frame

	var card_screen_pos := card.get_global_transform_with_canvas().origin
	card_screen_pos += card_top_offset

	var tooltip_size := tooltip_root.size

	tooltip_root.global_position = Vector2(
		card_screen_pos.x - tooltip_size.x * 0.5,
		card_screen_pos.y - tooltip_size.y - tooltip_gap
	)


func _hide_tooltip() -> void:
	if tooltip_instance != null:
		tooltip_instance.visible = false

	if tooltip_root != null:
		tooltip_root.visible = false


func _get_hovered_mutation() -> Mutation:
	if card == null:
		card = _find_card_parent()

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
	var rect := sprite.get_rect()

	return rect.has_point(local_mouse)


func _find_card_parent() -> Card:
	var current: Node = self

	while current != null:
		if current is Card:
			return current

		current = current.get_parent()

	return null
