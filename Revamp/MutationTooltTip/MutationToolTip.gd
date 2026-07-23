extends Control
class_name MutationToolTip


@export_group("Main Labels")
@export var name_label: Label
@export var description_label: Label

@export_group("Mutation Description Labels")
@export var mutation_description_label_1: Label
@export var mutation_description_label_2: Label
@export var mutation_description_label_3: Label

@export_group("Mutation Sprites")
@export var mutation_sprite_1: Sprite2D
@export var mutation_sprite_2: Sprite2D
@export var mutation_sprite_3: Sprite2D

@export_group("Text")
@export var no_mutations_text: String = "No mutations."

@export_group("Behaviour")
@export var show_empty_on_ready: bool = true

var current_mutation: Mutation = null
var current_card: CardRoot = null


func _ready() -> void:
	_hide_all_mutation_rows()

	if show_empty_on_ready:
		show_default_tooltip()
	else:
		hide()


func show_card(card: CardRoot) -> void:
	if card == null:
		show_default_tooltip()
		return

	if not is_instance_valid(card):
		show_default_tooltip()
		return

	current_card = card
	current_mutation = null

	if name_label != null:
		name_label.text = _get_card_display_name(card)
		name_label.visible = true

	_show_card_mutations(card)

	visible = true
	show()


func refresh_current_card() -> void:
	if current_card == null:
		return

	if not is_instance_valid(current_card):
		show_default_tooltip()
		return

	show_card(current_card)


func show_mutation(mutation: Mutation) -> void:
	if mutation == null:
		show_default_tooltip()
		return

	current_card = null
	current_mutation = mutation

	_hide_all_mutation_rows()

	if name_label != null:
		name_label.text = mutation.mutation_name
		name_label.visible = true

	if description_label != null:
		description_label.text = (
			mutation.mutation_description
		)
		description_label.visible = true

	visible = true
	show()


func hide_tooltip() -> void:
	show_default_tooltip()


func show_default_tooltip() -> void:
	current_card = null
	current_mutation = null

	_hide_all_mutation_rows()

	if name_label != null:
		name_label.text = ""
		name_label.visible = true

	if description_label != null:
		description_label.text = ""
		description_label.visible = true

	visible = true
	show()


func toggle_mutation(mutation: Mutation) -> void:
	if mutation == null:
		show_default_tooltip()
		return

	if current_mutation == mutation:
		show_default_tooltip()
		return

	show_mutation(mutation)


func _show_card_mutations(card: CardRoot) -> void:
	_hide_all_mutation_rows()

	if card.mutations == null:
		_set_no_mutations_text()
		return

	var mutation_list: Array[Mutation] = (
		card.mutations.get_all_mutations()
	)

	var valid_mutations: Array[Mutation] = []

	for mutation: Mutation in mutation_list:
		if mutation == null:
			continue

		valid_mutations.append(mutation)

	if valid_mutations.is_empty():
		_set_no_mutations_text()
		return

	if description_label != null:
		description_label.text = ""
		description_label.visible = false

	var visible_count: int = mini(
		valid_mutations.size(),
		3
	)

	for index: int in range(visible_count):
		_set_mutation_row(
			index,
			valid_mutations[index]
		)


func _set_mutation_row(
	index: int,
	mutation: Mutation
) -> void:
	if mutation == null:
		return

	var mutation_label: Label = (
		_get_mutation_description_label(index)
	)

	var mutation_sprite: Sprite2D = (
		_get_mutation_sprite(index)
	)

	if mutation_label != null:
		mutation_label.text = (
			mutation
				.mutation_description
				.strip_edges()
		)

		mutation_label.visible = true

	if mutation_sprite != null:
		mutation_sprite.texture = (
			mutation.sigil_texture
		)

		mutation_sprite.visible = true


func _hide_all_mutation_rows() -> void:
	var mutation_labels: Array[Label] = [
		mutation_description_label_1,
		mutation_description_label_2,
		mutation_description_label_3
	]

	for mutation_label: Label in mutation_labels:
		if mutation_label == null:
			continue

		mutation_label.visible = false

	var mutation_sprites: Array[Sprite2D] = [
		mutation_sprite_1,
		mutation_sprite_2,
		mutation_sprite_3
	]

	for mutation_sprite: Sprite2D in mutation_sprites:
		if mutation_sprite == null:
			continue

		mutation_sprite.texture = null
		mutation_sprite.visible = false


func _get_mutation_description_label(
	index: int
) -> Label:
	match index:
		0:
			return mutation_description_label_1

		1:
			return mutation_description_label_2

		2:
			return mutation_description_label_3

		_:
			return null


func _get_mutation_sprite(
	index: int
) -> Sprite2D:
	match index:
		0:
			return mutation_sprite_1

		1:
			return mutation_sprite_2

		2:
			return mutation_sprite_3

		_:
			return null


func _set_no_mutations_text() -> void:
	if description_label == null:
		return

	description_label.text = no_mutations_text
	description_label.visible = true


func _get_card_display_name(
	card: CardRoot
) -> String:
	var display_name: String = (
		card.card_name.strip_edges()
	)

	if not display_name.is_empty():
		return display_name

	return card.name
