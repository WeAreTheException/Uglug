extends Node
class_name MutationTooltipCoordinator


@export var mutation_tooltip: MutationToolTip

var hovered_card: CardRoot = null
var cursor_mutation: Mutation = null
var button_hover_mutation: Mutation = null


func _ready() -> void:
	refresh()


func set_hovered_card(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	hovered_card = card
	refresh()


func clear_hovered_card(card = null) -> void:
	if card == null:
		hovered_card = null
		refresh()
		return

	if not is_instance_valid(card):
		if not _has_valid_hovered_card():
			refresh()

		return

	if not _has_valid_hovered_card():
		refresh()
		return

	if hovered_card != card:
		return

	hovered_card = null
	refresh()


func set_cursor_mutation(
	mutation: Mutation
) -> void:
	cursor_mutation = mutation
	refresh()


func clear_cursor_mutation() -> void:
	cursor_mutation = null
	refresh()


func set_button_hover_mutation(
	mutation: Mutation
) -> void:
	button_hover_mutation = mutation
	refresh()


func clear_button_hover_mutation() -> void:
	button_hover_mutation = null
	refresh()


func clear_mutation_previews() -> void:
	cursor_mutation = null
	button_hover_mutation = null
	refresh()


func refresh() -> void:
	if mutation_tooltip == null:
		return

	if _has_valid_hovered_card():
		mutation_tooltip.show_card(
			hovered_card
		)
		return

	if cursor_mutation != null:
		mutation_tooltip.show_mutation(
			cursor_mutation
		)
		return

	if button_hover_mutation != null:
		mutation_tooltip.show_mutation(
			button_hover_mutation
		)
		return

	mutation_tooltip.show_default_tooltip()


func _has_valid_hovered_card() -> bool:
	if hovered_card == null:
		return false

	if not is_instance_valid(hovered_card):
		hovered_card = null
		return false

	return true
