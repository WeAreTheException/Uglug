extends Control
class_name MutationToolTip


@export_group("Labels")
@export var name_label: Label
@export var description_label: Label

@export_group("Mutation Rows")
@export var mutation_labels: Array[Label] = []
@export var mutation_sprites: Array[Sprite2D] = []

@export_group("Default Text")
@export var default_name_text: String = "Mutation"

@export_multiline var default_description_text: String = (
	"Hover over a card to see its mutations."
)

@export var no_mutations_text: String = "No mutations."

@export_group("Behaviour")
@export var show_default_on_ready: bool = true

var current_mutation: Mutation = null
var current_card: CardRoot = null


func _ready() -> void:
	_hide_all_mutation_rows()

	if show_default_on_ready:
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

	if description_label != null:
		description_label.text = (
			mutation.mutation_description
		)

	visible = true
	show()


func hide_tooltip() -> void:
	show_default_tooltip()


func show_default_tooltip() -> void:
	current_card = null
	current_mutation = null

	_hide_all_mutation_rows()

	if name_label != null:
		name_label.text = default_name_text

	if description_label != null:
		description_label.text = (
			default_description_text
		)

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

	var available_rows: int = mini(
		mutation_labels.size(),
		mutation_sprites.size()
	)

	var visible_count: int = mini(
		valid_mutations.size(),
		available_rows
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

	if index < 0:
		return

	if index >= mutation_labels.size():
		return

	if index >= mutation_sprites.size():
		return

	var mutation_label: Label = mutation_labels[index]
	var mutation_sprite: Sprite2D = mutation_sprites[index]

	if mutation_label != null:
		mutation_label.text = (
			_build_mutation_line_text(mutation)
		)

		mutation_label.visible = true

	if mutation_sprite != null:
		mutation_sprite.texture = (
			mutation.sigil_texture
		)

		mutation_sprite.visible = true


func _hide_all_mutation_rows() -> void:
	for mutation_label: Label in mutation_labels:
		if mutation_label == null:
			continue

		mutation_label.visible = false

	for mutation_sprite: Sprite2D in mutation_sprites:
		if mutation_sprite == null:
			continue

		mutation_sprite.texture = null
		mutation_sprite.visible = false


func _set_no_mutations_text() -> void:
	if description_label != null:
		description_label.text = no_mutations_text


func _build_mutation_line_text(
	mutation: Mutation
) -> String:
	if mutation == null:
		return ""

	return (
		mutation
			.mutation_description
			.strip_edges()
	)


func _get_card_display_name(card: CardRoot) -> String:
	var display_name: String = (
		card.card_name.strip_edges()
	)

	if display_name != "":
		return display_name

	return card.name


func _build_card_mutation_text(
	card: CardRoot
) -> String:
	if card.mutations == null:
		return no_mutations_text

	var mutation_list: Array[Mutation] = (
		card.mutations.get_all_mutations()
	)

	var lines: Array[String] = []

	for mutation: Mutation in mutation_list:
		if mutation == null:
			continue

		var line_text: String = (
			_build_mutation_line_text(mutation)
		)

		if line_text == "":
			continue

		lines.append(line_text)

	if lines.is_empty():
		return no_mutations_text

	return "\n".join(lines)
